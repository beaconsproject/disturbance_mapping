library(sf)
library(DT)
library(dplyr)
library(markdown)
library(leaflet)
library(bslib)

# Increase upload limit
options(shiny.maxRequestSize = 1000 * 1024^2)

# Google imagery
google <- "https://mts1.google.com/vt/lyrs=s&hl=en&src=app&x={x}&y={y}&z={z}&s=G"

# Default startup view: Yukon-wide bounding box (given in EPSG:3578 / Yukon Albers),
# converted once to lon/lat for Leaflet's fitBounds()
default_bbox <- st_bbox(c(xmin = 19075.03,    ymin = 41301.30,
                           xmax = 1336668.75, ymax = 1631797.73),
                         crs = st_crs(3578)) |>
  st_as_sfc() |>
  st_transform(4326) |>
  st_bbox()

# ==============================================================================
# OVERLAP DETECTION / FIX HELPERS  (ported from overlap_dashboard.qmd)
# ==============================================================================

# Colour key shared by the "Fix overlaps" map and its legend.
PAL <- c(
  "Exact duplicate" = "#d62728",
  "Partial overlap" = "#ff7f0e",
  "No overlap"      = "#3186cc",
  "Removed"         = "#9e9e9e"
)

# st_make_valid() can turn a repaired feature into a GEOMETRYCOLLECTION
# (polygon slivers mixed with stray lines/points), which leaflet cannot draw.
# Replace any such geometry with just its polygon (or line) parts, one row at
# a time so row order / count stay aligned with the uploaded layer.
planar_only <- function(x) {
  g  <- st_geometry(x)
  gt <- as.character(st_geometry_type(g))
  gc <- which(gt == "GEOMETRYCOLLECTION")
  if (!length(gc)) return(x)
  want  <- if (any(grepl("POLYGON", gt))) "POLYGON" else "LINESTRING"
  empty <- if (want == "POLYGON") st_polygon() else st_linestring()
  crs   <- st_crs(x)
  gl <- lapply(seq_along(g), function(i) {
    if (!(i %in% gc)) return(g[[i]])
    out <- tryCatch(
      suppressWarnings(st_collection_extract(st_sfc(g[[i]], crs = crs), want)),
      error = function(e) NULL
    )
    if (is.null(out) || length(out) == 0) empty else out[[1]]
  })
  st_geometry(x) <- st_sfc(gl, crs = crs)
  x
}

# Repair geometries, then classify every feature against the rest of the layer:
#   exact_sp       - spatially equal to another feature (st_equals)
#   exact_spattr   - spatially equal AND all attributes identical
#   partial_sp     - partial spatial overlap with another feature (st_overlaps)
#   partial_spattr - partial overlap AND all attributes identical
# eq / ov keep the neighbour index lists so the fix step can group features.
overlap_analysis <- function(x) {
  x <- planar_only(st_make_valid(x))
  n <- nrow(x)
  nonempty <- !st_is_empty(x)

  eq_raw <- st_equals(x)
  ov     <- lapply(st_overlaps(x), as.integer)
  eq     <- lapply(seq_len(n), function(i) as.integer(setdiff(eq_raw[[i]], i)))

  adf  <- st_drop_geometry(x)
  akey <- if (ncol(adf) > 0) {
    do.call(paste, c(lapply(adf, as.character), sep = ""))
  } else {
    rep("", n)
  }

  attr_match <- function(nb, i) length(nb) > 0 && any(akey[nb] == akey[i])

  exact_sp       <- lengths(eq) > 0 & nonempty
  partial_sp     <- lengths(ov) > 0 & nonempty
  exact_spattr   <- vapply(seq_len(n), function(i) nonempty[i] && attr_match(eq[[i]], i), logical(1))
  partial_spattr <- vapply(seq_len(n), function(i) nonempty[i] && attr_match(ov[[i]], i), logical(1))
  flagged        <- exact_sp | partial_sp

  # Connected clusters of overlapping features (exact + partial links). Each
  # cluster gets a shared group_id; group_type is "Exact" when every member
  # shares the same geometry (all pairwise st_equals), otherwise "Partial".
  adj <- lapply(seq_len(n), function(i) union(eq[[i]], ov[[i]]))
  group_id <- rep(NA_integer_, n)
  k <- 0L
  for (i in seq_len(n)) {
    if (!flagged[i] || !is.na(group_id[i])) next
    k <- k + 1L
    stack <- i
    while (length(stack)) {
      v <- stack[[1]]
      stack <- stack[-1]
      if (!is.na(group_id[v])) next
      group_id[v] <- k
      nb <- adj[[v]]
      stack <- c(stack, nb[is.na(group_id[nb])])
    }
  }
  group_type <- rep(NA_character_, n)
  for (g in seq_len(k)) {
    idx <- which(group_id == g)
    all_equal <- all(vapply(idx, function(i) setequal(c(i, eq[[i]]), idx), logical(1)))
    group_type[idx] <- if (all_equal) "Exact" else "Partial"
  }

  list(
    x    = x,
    akey = akey,
    eq   = eq,
    ov   = ov,
    exact_sp       = exact_sp,
    exact_spattr   = exact_spattr,
    partial_sp     = partial_sp,
    partial_spattr = partial_spattr,
    group_id       = group_id,
    group_type     = group_type
  )
}

# The five summary rows for one analysis (feature counts).
counts_vec <- function(a) c(
  "Total features"                          = nrow(a$x),
  "Exact duplicates (spatial only)"         = sum(a$exact_sp),
  "Exact duplicates (spatial + attributes)" = sum(a$exact_spattr),
  "Partial overlaps (spatial only)"         = sum(a$partial_sp),
  "Partial overlaps (spatial + attributes)" = sum(a$partial_spattr)
)

# Row indices to drop. Build clusters of overlapping features (exact links
# always; partial links when fix_partial; keep only identical-attribute links
# when attr_only), then in each cluster keep the first feature and drop the
# rest. The saved layer is therefore the original features minus these rows.
removal_indices <- function(a, fix_partial, attr_only) {
  n <- nrow(a$x)
  if (n == 0) return(integer(0))

  adj <- vector("list", n)
  for (i in seq_len(n)) {
    nb <- a$eq[[i]]
    if (fix_partial) nb <- union(nb, a$ov[[i]])
    if (attr_only && length(nb)) nb <- nb[a$akey[nb] == a$akey[i]]
    adj[[i]] <- as.integer(nb)
  }

  comp <- rep(NA_integer_, n)
  k <- 0L
  for (i in seq_len(n)) {
    if (!is.na(comp[i]) || length(adj[[i]]) == 0) next
    k <- k + 1L
    stack <- i
    while (length(stack)) {
      v <- stack[[1]]
      stack <- stack[-1]
      if (!is.na(comp[v])) next
      comp[v] <- k
      nxt <- adj[[v]]
      stack <- c(stack, nxt[is.na(comp[nxt])])
    }
  }

  drop <- integer(0)
  for (g in seq_len(k)) {
    idx <- which(comp == g)
    if (length(idx) > 1) drop <- c(drop, sort(idx)[-1])
  }
  sort(unique(drop))
}

# Add a line or polygon layer to the map, coloured by category. Empty
# geometries (features dropped by geometry repair) are skipped.
add_features <- function(map, d, category, faded = FALSE, group = NULL) {
  ok <- !st_is_empty(d)
  d  <- d[ok, , drop = FALSE]
  category <- category[ok]
  if (nrow(d) == 0) return(map)
  col     <- unname(PAL[category])
  is_line <- any(grepl("LINESTRING", as.character(st_geometry_type(d))))
  if (is_line) {
    addPolylines(
      map, data = d, color = col, group = group,
      weight = if (faded) 2 else 3, opacity = if (faded) 0.4 else 0.9,
      dashArray = if (faded) "4" else NULL, label = category
    )
  } else {
    addPolygons(
      map, data = d, color = col, weight = 1, group = group,
      opacity = if (faded) 0.4 else 0.9,
      fillColor = col, fillOpacity = if (faded) 0.1 else 0.45,
      dashArray = if (faded) "4" else NULL, label = category
    )
  }
}

ui <- page_navbar(
  title = "Disturbance Validation",
  theme = bs_theme(
    version    = 5,
    bootswatch = "cosmo"
  ) |>
    bs_add_rules("
  .navbar {
    background-color: #006400 !important;
  }
  .navbar .navbar-brand,
  .navbar .nav-link {
    color: #FFFFFF !important;
  }
  .navbar .nav-link:hover,
  .navbar .nav-link.active {
    color: #FFFFFF !important;
  }
  table.dataTable tbody tr.selected,
  table.dataTable tbody tr.selected td {
    background-color: #ffff00 !important;
    color: #000000 !important;
  }
  table.dataTable tbody tr.selected > * {
    box-shadow: inset 0 0 0 9999px rgba(255, 255, 0, 0.5) !important;
  }
  table.dataTable tbody tr.grp-hl td {
    background-color: #ffe08a !important;
  }
"),
  
  # 1. VIEW FEATURES TAB
  nav_panel(
    title = "View features",
    layout_sidebar(
      sidebar = sidebar(width=280,
            markdown("**1. Upload data**"),
            fileInput("gpkg", "Geopackage:", accept = ".gpkg"),
            hr(),
            
            markdown("**2. Select layers**"),
            selectInput("bnd",  "Study area:",          choices = NULL),
            selectInput("line", "Linear disturbances:", choices = NULL),
            selectInput("poly",      "Areal disturbances:",  choices = NULL),
            hr(),
            
            markdown("**3. View disturbances**"),
            actionButton("mapButton", "Map features", class = "btn-primary w-100"),
            hr(),
            markdown("**4. Select random features**"),
            actionButton("randomLine", "Linear feature",
                         icon  = icon("shuffle"),
                         class = "btn-outline-primary w-100"),
            actionButton("randomPoly", "Areal feature",
                         icon  = icon("shuffle"),
                         class = "btn-outline-primary w-100"),
            hr(),
            markdown("**5. Edit & save**"),
            markdown("Click any cell in the Linear or Areal attribute panels to edit its value."),
            tooltip(
              actionButton("saveEdits", "Save existing geopackage",
                           icon  = icon("floppy-disk"),
                           class = "btn-warning w-100"),
              "Keeps your corrections for the rest of this session. Nothing is downloaded, and edits are lost if the app is closed or restarted."
            ),
            tooltip(
              downloadButton("downloadGpkgView", "Save as new geopackage",
                             icon  = icon("download"),
                             class = "btn-success w-100"),
              "Downloads a new .gpkg file to your computer with all your edits included. Use this before closing the app if you want to keep your work."
            )
      ),
      
      layout_columns(
        col_widths = c(9, 3),
        
        # Left: map + full attribute tables
        navset_card_tab(
          id          = "featureViewTabs",
          height      = 750,
          full_screen = TRUE,
          nav_panel("Map view",         leafletOutput("map", height = "100%")),
          nav_panel("Attribute tables",
            card(
              height      = "50%",
              full_screen = TRUE,
              card_header("Linear features"),
              DTOutput("table_line")
            ),
            card(
              height      = "50%",
              full_screen = TRUE,
              card_header("Areal features"),
              DTOutput("table_poly")
            )
          ),
          nav_panel("Help",        includeMarkdown("www/help.md")),
        ),
        
        # Right: per-feature attribute cards
        layout_columns(
          col_widths = 12,
          card(
            height      = 300,
            full_screen = TRUE,
            card_header("Linear attributes"),
            DTOutput("table1")
          ),
          card(
            height      = 300,
            full_screen = TRUE,
            card_header("Areal attributes"),
            DTOutput("table2")
          )
        )
      )
    )
  ),
  
  # 2. VALIDATE ATTRIBUTES TAB
  nav_panel(
    title = "Validate attributes",
    #icon  = icon("check-circle"),
    layout_sidebar(
      sidebar = sidebar(width=280,
        markdown("**1. Upload reference file**"),
        markdown("Upload a CSV file containing the expected attribute values for validation. The CSV should have the following columns: TYPE_FEATURE, TYPE_INDUSTRY, TYPE_DISTURBANCE."),
        fileInput("csv", "Upload CSV file:", accept = ".csv"),
        hr(),
        markdown("**2. Validate attribute values**"),
        actionButton("valButton", "Validate values", class = "btn-success w-100"),
        hr(),
        markdown("**3. Edit & save**"),
        markdown("Click any TYPE_INDUSTRY or TYPE_DISTURBANCE cell in the error tables to edit its value."),
        tooltip(
          actionButton("saveValEdits", "Save existing geopackage",
                       icon  = icon("floppy-disk"),
                       class = "btn-warning w-100"),
          "Keeps your corrections for the rest of this session. Nothing is downloaded, and edits are lost if the app is closed or restarted."
        ),
        tooltip(
          downloadButton("downloadGpkgVal", "Save as new geopackage",
                         icon  = icon("download"),
                         class = "btn-success w-100"),
          "Downloads a new .gpkg file to your computer with all your edits included. Use this before closing the app if you want to keep your work."
        )
      ),
      navset_card_tab(
        full_screen = TRUE,
        nav_panel("Linear errors",  DTOutput("linearTable")),
        nav_panel("Areal errors",   DTOutput("arealTable")),
        nav_panel("Permitted values", DTOutput("types"))
      )
    )
  ),

  # 3. FIX OVERLAPS TAB
  nav_panel(
    title = "Fix overlaps",
    layout_sidebar(
      sidebar = sidebar(width = 300,
        markdown("**1. View overlaps**"),
        markdown("Uses the geopackage uploaded in the **View features** tab."),
        uiOutput("ov_layer_ui"),
        actionButton("ov_calc", "Calculate and view overlaps",
                     class = "btn-primary w-100"),
        hr(),

        markdown("**2. Fix overlaps**"),
        checkboxInput("ov_fix_pp", "Fix overlaps (exact and partial)", value = TRUE),
        checkboxInput("ov_attr_only", "Only fix if attributes identical", value = TRUE),
        actionButton("ov_fix", "Remove selected overlaps",
                     class = "btn-warning w-100"),
        helpText(
          "Unchecked “exact and partial” removes only exact duplicates. ",
          "In each overlap cluster the first feature is kept and the rest removed; ",
          "“attributes identical” limits this to features whose attributes all match."
        ),
        hr(),

        markdown("**3. Save changes**"),
        downloadButton("ov_save", "Save as new geopackage",
                       icon  = icon("download"),
                       class = "btn-success w-100")
      ),

      layout_columns(
        col_widths = c(6, 6),

        card(
          full_screen = TRUE,
          height      = 750,
          card_header("Map"),
          leafletOutput("ov_map", height = "100%")
        ),

        layout_columns(
          col_widths = 12,
          card(
            full_screen = TRUE,
            height      = 260,
            card_header("Overlap summary"),
            DTOutput("ov_summary")
          ),
          card(
            full_screen = TRUE,
            height      = 480,
            card_header("Overlapping feature attributes"),
            DTOutput("ov_attributes")
          )
        )
      )
    )
  )
)

# ==============================================================================
# SERVER
# ==============================================================================

server <- function(input, output, session) {
  
  # --- Reactive Reference table from File Input -------------------------------
  types <- reactive({
    req(input$csv)
    readr::read_csv(input$csv$datapath)
  })
  
  output$types <- renderDataTable({
    req(types())
    datatable(types(), rownames = FALSE,
              options = list(dom = 'tip', scrollX = TRUE,
                             scrollY = TRUE, pageLength = 25),
              class = "compact")
  })
  
  # --- Layer selection after upload -------------------------------------------
  observeEvent(input$gpkg, {
    lyrs <- st_layers(input$gpkg$datapath)$name
    updateSelectInput(session, "bnd",  choices = lyrs, selected = 'studyarea')
    updateSelectInput(session, "line", choices = lyrs, selected = 'linear_disturbance')
    updateSelectInput(session, "poly", choices = lyrs, selected = 'areal_disturbance')
  })
  
  # --- Base spatial reactives -------------------------------------------------
  bnd <- eventReactive(input$mapButton, {
    req(input$gpkg)
    st_read(input$gpkg$datapath, input$bnd, quiet = TRUE) |> st_transform(4326)
  })
  
  line_base <- eventReactive(input$mapButton, {
    req(input$gpkg)
    st_read(input$gpkg$datapath, input$line, quiet = TRUE) |>
      st_transform(4326) |>
      mutate(line_id = paste0('L', seq_len(n())))
  })
  
  poly_base <- eventReactive(input$mapButton, {
    req(input$gpkg)
    st_read(input$gpkg$datapath, input$poly, quiet = TRUE) |>
      st_transform(4326) |>
      mutate(poly_id = paste0('P', seq_len(n())))
  })
  
  # --- Editable attribute tables ----------------------------------------------
  line_attrs       <- reactiveVal(NULL)
  poly_attrs       <- reactiveVal(NULL)

  observeEvent(line_base(), { line_attrs(st_drop_geometry(line_base())) })
  observeEvent(poly_base(), { poly_attrs(st_drop_geometry(poly_base())) })

  selected_line_id   <- reactiveVal(NULL)
  selected_poly_id   <- reactiveVal(NULL)

  # --- Map --------------------------------------------------------------------
  output$map <- renderLeaflet({
    m <- leaflet(options = leafletOptions(attributionControl = FALSE)) |>
      addTiles(google, group = "Google.Imagery") |>
      addProviderTiles("Esri.WorldTopoMap", group = "Esri.WorldTopoMap") |>
      addProviderTiles("Esri.WorldImagery", group = "Esri.WorldImagery") |>
      fitBounds(lng1 = default_bbox[["xmin"]], lat1 = default_bbox[["ymin"]],
                lng2 = default_bbox[["xmax"]], lat2 = default_bbox[["ymax"]])

    base_groups <- c("Esri.WorldTopoMap", "Esri.WorldImagery", "Google.Imagery")

    if (!is.null(input$gpkg) && input$mapButton > 0) {
      overlay_groups <- c("Study area", "Areal disturbances", "Linear disturbances")
      bbox <- st_bbox(bnd())
      m <- m |>
        addPolygons(data = bnd(), fill = FALSE, weight = 2, color = 'blue',
                    group = "Study area") |>
        addPolygons(data = poly_base(), fill = TRUE, weight = 1, color = 'red',
                    fillOpacity = 0.5, layerId = poly_base()$poly_id,
                    group = "Areal disturbances") |>
        addPolylines(data = line_base(), weight = 2, color = 'red',
                     layerId = line_base()$line_id,
                     group = "Linear disturbances") |>
        fitBounds(lng1 = bbox[["xmin"]], lat1 = bbox[["ymin"]],
                  lng2 = bbox[["xmax"]], lat2 = bbox[["ymax"]])

      m <- m |>
        addLayersControl(
          position      = "topright",
          baseGroups    = base_groups,
          overlayGroups = overlay_groups,
          options       = layersControlOptions(collapsed = FALSE)
        )
    } else {
      m <- m |>
        addLayersControl(
          position   = "topright",
          baseGroups = base_groups,
          options    = layersControlOptions(collapsed = FALSE)
        )
    }
    m
  })
  
  # --- Full feature tables ----------------------------------------------------
  saved_line_attrs <- reactiveVal(NULL)
  saved_poly_attrs <- reactiveVal(NULL)
  
  observeEvent(line_attrs(), { saved_line_attrs(line_attrs()) }, once = TRUE)
  observeEvent(poly_attrs(), { saved_poly_attrs(poly_attrs()) }, once = TRUE)
  
  output$table_line <- renderDT({
    req(saved_line_attrs())
    datatable(saved_line_attrs(), rownames = FALSE, selection = "single",
              options = list(dom = 'tip', pageLength = 15))
  })

  output$table_poly <- renderDT({
    req(saved_poly_attrs())
    datatable(saved_poly_attrs(), rownames = FALSE, selection = "single",
              options = list(dom = 'tip', pageLength = 15))
  })
  
  render_editable <- function(df_row) {
    tdf        <- as.data.frame(t(df_row), stringsAsFactors = FALSE)
    colnames(tdf) <- "Value"
    datatable(
      tdf,
      rownames = TRUE,
      editable = list(target = "cell", disable = list(columns = 0L)),
      options  = list(dom = 't', scrollY = TRUE, pageLength = nrow(tdf))
    )
  }
  
  output$table1 <- renderDT({
    req(line_attrs(), selected_line_id())
    row <- filter(line_attrs(), line_id == selected_line_id())
    req(nrow(row) > 0)
    render_editable(row)
  })
  
  output$table2 <- renderDT({
    req(poly_attrs(), selected_poly_id())
    row <- filter(poly_attrs(), poly_id == selected_poly_id())
    req(nrow(row) > 0)
    render_editable(row)
  })
  
  observeEvent(input$map_shape_click, {
    id <- input$map_shape_click$id
    req(id)
    if      (grepl("^P",   id)) selected_poly_id(id)
    else if (grepl("^L",   id)) selected_line_id(id)
  })

  # --- Selection highlighting (map <-> attribute tables) ----------------------
  line_table_proxy <- dataTableProxy("table_line")
  poly_table_proxy <- dataTableProxy("table_poly")

  observeEvent(input$table_line_rows_selected, {
    req(saved_line_attrs())
    idx <- input$table_line_rows_selected
    if (length(idx) > 0) selected_line_id(saved_line_attrs()$line_id[idx])
  })

  observeEvent(input$table_poly_rows_selected, {
    req(saved_poly_attrs())
    idx <- input$table_poly_rows_selected
    if (length(idx) > 0) selected_poly_id(saved_poly_attrs()$poly_id[idx])
  })

  observeEvent(selected_line_id(), {
    req(saved_line_attrs())
    selectRows(line_table_proxy, which(saved_line_attrs()$line_id == selected_line_id()))
  }, ignoreNULL = FALSE)

  observeEvent(selected_poly_id(), {
    req(saved_poly_attrs())
    selectRows(poly_table_proxy, which(saved_poly_attrs()$poly_id == selected_poly_id()))
  }, ignoreNULL = FALSE)

  observeEvent(selected_line_id(), {
    proxy <- leafletProxy("map") |> clearGroup("Selected linear")
    req(selected_line_id(), line_base())
    feat <- line_base() |> filter(line_id == selected_line_id())
    req(nrow(feat) > 0)
    proxy |> addPolylines(data = feat, color = "yellow", weight = 6, opacity = 1,
                           group = "Selected linear")
  }, ignoreNULL = FALSE)

  observeEvent(selected_poly_id(), {
    proxy <- leafletProxy("map") |> clearGroup("Selected areal")
    req(selected_poly_id(), poly_base())
    feat <- poly_base() |> filter(poly_id == selected_poly_id())
    req(nrow(feat) > 0)
    proxy |> addPolygons(data = feat, color = "yellow", weight = 5, fill = FALSE, opacity = 1,
                          group = "Selected areal")
  }, ignoreNULL = FALSE)

  # --- Random feature selection -------------------------------------------
  observeEvent(input$randomLine, {
    req(line_base())
    feat <- line_base() |> slice_sample(n = 1)
    req(nrow(feat) > 0)
    selected_line_id(feat$line_id)
    bbox <- st_bbox(feat)
    leafletProxy("map") |>
      flyToBounds(lng1 = bbox[["xmin"]], lat1 = bbox[["ymin"]],
                  lng2 = bbox[["xmax"]], lat2 = bbox[["ymax"]],
                  options = list(maxZoom = 16))
    nav_select("featureViewTabs", "Map view")
  })

  observeEvent(input$randomPoly, {
    req(poly_base())
    feat <- poly_base() |> slice_sample(n = 1)
    req(nrow(feat) > 0)
    selected_poly_id(feat$poly_id)
    bbox <- st_bbox(feat)
    leafletProxy("map") |>
      flyToBounds(lng1 = bbox[["xmin"]], lat1 = bbox[["ymin"]],
                  lng2 = bbox[["xmax"]], lat2 = bbox[["ymax"]],
                  options = list(maxZoom = 16))
    nav_select("featureViewTabs", "Map view")
  })

  apply_edit <- function(attrs, selected_id, id_col, info) {
    df        <- attrs()
    row_match <- df[[id_col]] == selected_id()
    attr_name <- names(df)[info$row]
    new_val   <- tryCatch(
      methods::as(info$value, class(df[[attr_name]])[1]),
      error = function(e) info$value
    )
    df[row_match, attr_name] <- new_val
    attrs(df)
  }
  
  observeEvent(input$table1_cell_edit, {
    req(line_attrs(), selected_line_id())
    apply_edit(line_attrs, selected_line_id, "line_id", input$table1_cell_edit)
  })
  
  observeEvent(input$table2_cell_edit, {
    req(poly_attrs(), selected_poly_id())
    apply_edit(poly_attrs, selected_poly_id, "poly_id", input$table2_cell_edit)
  })
  
  # --- Write current edits into the existing (uploaded) geopackage ------------
  save_to_existing_gpkg <- function() {
    req(input$gpkg, line_base(), poly_base(), line_attrs(), poly_attrs())
    dsn     <- input$gpkg$datapath
    line_sf <- st_sf(line_attrs() |> select(-line_id), geometry = st_geometry(line_base()))
    poly_sf <- st_sf(poly_attrs() |> select(-poly_id), geometry = st_geometry(poly_base()))
    st_write(line_sf, dsn = dsn, layer = input$line, driver = "GPKG", delete_layer = TRUE, quiet = TRUE)
    st_write(poly_sf, dsn = dsn, layer = input$poly, driver = "GPKG", delete_layer = TRUE, quiet = TRUE)
  }

  observeEvent(input$saveEdits, {
    req(line_attrs(), poly_attrs())
    saved_line_attrs(line_attrs())
    saved_poly_attrs(poly_attrs())
    save_to_existing_gpkg()
    showNotification("Edits saved to the existing geopackage.", type = "message", duration = 3)
  })

  new_gpkg_handler <- downloadHandler(
    filename = function() {
      paste0("disturbance_edited_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".gpkg")
    },
    content = function(file) {
      req(input$gpkg, line_base(), poly_base(), line_attrs(), poly_attrs())
      src_path    <- input$gpkg$datapath
      all_lyrs    <- st_layers(src_path)$name
      edited_lyrs <- c(input$line, input$poly)
      line_sf <- st_sf(line_attrs() |> select(-line_id), geometry = st_geometry(line_base()))
      poly_sf <- st_sf(poly_attrs() |> select(-poly_id), geometry = st_geometry(poly_base()))
      st_write(line_sf, dsn = file, layer = input$line, driver = "GPKG", quiet = TRUE)
      st_write(poly_sf, dsn = file, layer = input$poly, driver = "GPKG", append = TRUE, quiet = TRUE)
      for (lyr in setdiff(all_lyrs, edited_lyrs)) {
        other_sf <- tryCatch(st_read(src_path, lyr, quiet = TRUE), error = function(e) NULL)
        if (!is.null(other_sf)) st_write(other_sf, dsn = file, layer = lyr, driver = "GPKG", append = TRUE, quiet = TRUE)
      }
    }
  )
  output$downloadGpkgView <- new_gpkg_handler
  output$downloadGpkgVal  <- new_gpkg_handler

  # --- Validation -------------------------------------------------------------
  validate_df <- function(df, feature_type) {
    req(types()) # Ensures dynamic csv data is loaded before running validation
    indu  <- types() |> filter(TYPE_FEATURE == feature_type) |> pull(TYPE_INDUSTRY)   |> unique()
    dist  <- types() |> filter(TYPE_FEATURE == feature_type) |> pull(TYPE_DISTURBANCE)|> unique()
    combo <- types() |> filter(TYPE_FEATURE == feature_type) |>
      mutate(C = paste0(TYPE_INDUSTRY, "***", TYPE_DISTURBANCE)) |> pull(C) |> unique()
    df |>
      mutate(
        industry_test    = ifelse(TYPE_INDUSTRY    %in% indu,  'ok', 'please fix'),
        disturbance_test = ifelse(TYPE_DISTURBANCE %in% dist,  'ok', 'please fix'),
        combination_test = ifelse(paste0(TYPE_INDUSTRY, "***", TYPE_DISTURBANCE) %in% combo, 'ok', 'not expected')
      )
  }
  
  # --- Error tables: restricted columns, editable TYPE_INDUSTRY/TYPE_DISTURBANCE ----
  # id_col (line_id/poly_id) is shown (read-only) so rows can be traced back to source features.
  error_rows <- function(df, feature_type, id_col) {
    validate_df(df, feature_type) |>
      filter(industry_test != 'ok' | disturbance_test != 'ok' | combination_test != 'ok') |>
      select(all_of(c(id_col, "TYPE_INDUSTRY", "TYPE_DISTURBANCE",
                       "industry_test", "disturbance_test", "combination_test")))
  }

  linear_errors <- reactiveVal(NULL)
  areal_errors  <- reactiveVal(NULL)

  observeEvent(input$valButton, {
    req(saved_line_attrs(), saved_poly_attrs())
    linear_errors(error_rows(saved_line_attrs(), 'Linear', "line_id"))
    areal_errors(error_rows(saved_poly_attrs(), 'Areal', "poly_id"))
  })

  output$linearTable <- renderDT({
    req(linear_errors())
    datatable(linear_errors(), rownames = FALSE,
              editable = list(target = "cell", disable = list(columns = c(0, 3, 4, 5))),
              options  = list(dom = 'tip', pageLength = 15))
  })

  output$arealTable <- renderDT({
    req(areal_errors())
    datatable(areal_errors(), rownames = FALSE,
              editable = list(target = "cell", disable = list(columns = c(0, 3, 4, 5))),
              options  = list(dom = 'tip', pageLength = 15))
  })

  observeEvent(input$linearTable_cell_edit, {
    req(linear_errors())
    linear_errors(editData(linear_errors(), input$linearTable_cell_edit, rownames = FALSE))
  })

  observeEvent(input$arealTable_cell_edit, {
    req(areal_errors())
    areal_errors(editData(areal_errors(), input$arealTable_cell_edit, rownames = FALSE))
  })

  observeEvent(input$saveValEdits, {
    req(linear_errors(), areal_errors(), line_attrs(), poly_attrs())

    # Push corrected TYPE_INDUSTRY / TYPE_DISTURBANCE back into the master tables
    ldf <- line_attrs()
    for (i in seq_len(nrow(linear_errors()))) {
      lid <- linear_errors()$line_id[i]
      ldf[ldf$line_id == lid, c("TYPE_INDUSTRY", "TYPE_DISTURBANCE")] <-
        linear_errors()[i, c("TYPE_INDUSTRY", "TYPE_DISTURBANCE")]
    }
    line_attrs(ldf)
    saved_line_attrs(ldf)

    pdf <- poly_attrs()
    for (i in seq_len(nrow(areal_errors()))) {
      pid <- areal_errors()$poly_id[i]
      pdf[pdf$poly_id == pid, c("TYPE_INDUSTRY", "TYPE_DISTURBANCE")] <-
        areal_errors()[i, c("TYPE_INDUSTRY", "TYPE_DISTURBANCE")]
    }
    poly_attrs(pdf)
    saved_poly_attrs(pdf)

    # Re-validate so corrected rows drop out (or update) in the error tables
    linear_errors(error_rows(ldf, 'Linear', "line_id"))
    areal_errors(error_rows(pdf, 'Areal', "poly_id"))

    save_to_existing_gpkg()
    showNotification("Corrections saved to the existing geopackage and re-validated.", type = "message", duration = 3)
  })

  # ==========================================================================
  # FIX OVERLAPS TAB  (ported from overlap_dashboard.qmd)
  # Reuses the geopackage uploaded on the "View features" tab (input$gpkg);
  # only the layer to check is chosen here.
  # ==========================================================================

  ov_vals <- reactiveValues(src = NULL, before = NULL, after = NULL,
                            removed = integer(0))

  # --- list the layers in the uploaded GeoPackage ---------------------------
  output$ov_layer_ui <- renderUI({
    f <- input$gpkg
    if (is.null(f))
      return(helpText("No geopackage uploaded yet — upload one on the “View features” tab."))
    lyrs <- tryCatch(st_layers(f$datapath)$name, error = function(e) character(0))
    if (!length(lyrs)) return(helpText("No layers found in this GeoPackage."))
    selectInput("ov_layer", "Layer", choices = lyrs)
  })

  # --- read the selected layer -------------------------------------------
  observeEvent(list(input$gpkg, input$ov_layer), {
    req(input$gpkg, input$ov_layer)
    x <- tryCatch(st_read(input$gpkg$datapath, input$ov_layer, quiet = TRUE),
                  error = function(e) NULL)
    if (is.null(x) || nrow(x) == 0) {
      showNotification("Could not read that layer (or it is empty).", type = "error")
      return(invisible())
    }
    gt <- as.character(st_geometry_type(x))
    if (!any(grepl("LINESTRING|POLYGON", gt))) {
      showNotification("Please select a line or polygon layer.", type = "error")
      return(invisible())
    }
    if (is.na(st_crs(x))) {
      showNotification("Layer has no CRS — it cannot be mapped.", type = "error")
      return(invisible())
    }
    ov_vals$src     <- x
    ov_vals$before  <- NULL
    ov_vals$after   <- NULL
    ov_vals$removed <- integer(0)
  }, ignoreInit = TRUE)

  # --- calculate and view overlaps -------------------------------------
  observeEvent(input$ov_calc, {
    req(ov_vals$src)
    withProgress(message = "Detecting overlaps…", {
      ov_vals$before <- overlap_analysis(ov_vals$src)
    })
    ov_vals$after   <- NULL
    ov_vals$removed <- integer(0)
  })

  # --- remove selected overlaps --------------------------------------
  observeEvent(input$ov_fix, {
    req(ov_vals$before)
    rem <- removal_indices(ov_vals$before, isTRUE(input$ov_fix_pp), isTRUE(input$ov_attr_only))
    ov_vals$removed <- rem
    reduced <- if (length(rem)) ov_vals$before$x[-rem, ] else ov_vals$before$x
    withProgress(message = "Re-checking after fix…", {
      ov_vals$after <- overlap_analysis(reduced)
    })
    showNotification(sprintf("%d feature(s) removed.", length(rem)), type = "message")
  })

  # --- summary table (Attribute / Before / After) ----------------------
  output$ov_summary <- renderDT({
    rb <- ov_vals$before
    req(rb)
    before <- counts_vec(rb)
    df <- data.frame(
      Attribute = names(before),
      Before    = as.integer(before),
      After     = if (is.null(ov_vals$after)) "" else as.integer(counts_vec(ov_vals$after)),
      check.names = FALSE, stringsAsFactors = FALSE
    )
    datatable(
      df, rownames = FALSE,
      options = list(
        dom = "t", paging = FALSE, ordering = FALSE,
        columnDefs = list(list(className = "dt-center", targets = 1:2))
      )
    )
  })

  # --- attributes of the overlapping features ------------------------
  output$ov_attributes <- renderDT({
    rb <- ov_vals$before
    req(rb)
    flagged <- which(rb$exact_sp | rb$partial_sp)
    if (!length(flagged)) {
      return(datatable(data.frame(Message = "No overlapping features."),
                       rownames = FALSE, options = list(dom = "t")))
    }
    ord <- flagged[order(rb$group_id[flagged], flagged)]
    tbl <- data.frame(
      Overlap_id   = rb$group_id[ord],
      Overlap_type = rb$group_type[ord],
      check.names = FALSE, stringsAsFactors = FALSE
    )
    if (length(ov_vals$removed)) {
      tbl$Status <- ifelse(ord %in% ov_vals$removed, "Removed", "Kept")
    }
    tbl <- cbind(tbl, st_drop_geometry(rb$x)[ord, , drop = FALSE])
    datatable(
      tbl, rownames = FALSE, filter = "top", selection = "none",
      options = list(
        dom = "tip", pageLength = 15, scrollX = TRUE,
        drawCallback = JS(
          "function() {",
          "  if (window._ovGrpHl == null) return;",
          "  var api = this.api();",
          "  $(api.table().body()).find('tr').removeClass('grp-hl');",
          "  api.rows({page: 'current'}).every(function() {",
          "    if (String(this.data()[0]) === window._ovGrpHl) $(this.node()).addClass('grp-hl');",
          "  });",
          "}"
        )
      ),
      callback = JS(
        "window._ovGrpHl = null;",
        "table.on('click', 'tbody tr', function() {",
        "  var d = table.row(this).data();",
        "  if (!d) return;",
        "  var gid = String(d[0]);",
        "  window._ovGrpHl = gid;",
        "  $(table.table().body()).find('tr').removeClass('grp-hl');",
        "  table.rows({page: 'current'}).every(function() {",
        "    if (String(this.data()[0]) === gid) $(this.node()).addClass('grp-hl');",
        "  });",
        "  Shiny.setInputValue('ov_attr_group_click', gid, {priority: 'event'});",
        "});"
      )
    )
  })

  # --- map ------------------------------------------------------------
  # The base map (tiles + basemap switcher) is built once; features and the
  # legend are drawn through a proxy so they refresh on every Calculate / fix
  # without rebuilding the widget or losing the current zoom.
  output$ov_map <- renderLeaflet({
    leaflet(options = leafletOptions(attributionControl = FALSE)) |>
      addProviderTiles("Esri.WorldTopoMap",    group = "Esri topo") |>
      addProviderTiles("Esri.WorldImagery",    group = "Esri imagery") |>
      addProviderTiles("Esri.WorldGrayCanvas", group = "Esri grey") |>
      addLayersControl(
        baseGroups = c("Esri topo", "Esri imagery", "Esri grey"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })

  observe({
    proxy <- leafletProxy("ov_map")
    proxy |>
      clearGroup("features") |>
      clearGroup("removed") |>
      clearGroup("highlight") |>
      removeControl("legend")

    rb  <- ov_vals$before
    src <- ov_vals$src

    # before "Calculate": show the raw layer (or nothing yet), no legend
    if (is.null(rb)) {
      if (!is.null(src)) {
        d0 <- planar_only(st_transform(src, 4326))
        add_features(proxy, d0, rep("No overlap", nrow(d0)), group = "features")
        bb <- as.numeric(st_bbox(d0))
        if (all(is.finite(bb))) proxy |> fitBounds(bb[1], bb[2], bb[3], bb[4])
      }
      return()
    }

    disp <- st_transform(rb$x, 4326)
    n    <- nrow(disp)
    ra   <- ov_vals$after
    rem  <- ov_vals$removed

    if (is.null(ra)) {
      category <- ifelse(rb$exact_sp, "Exact duplicate",
                  ifelse(rb$partial_sp, "Partial overlap", "No overlap"))
      keep_idx <- seq_len(n)
    } else {
      category <- rep("No overlap", n)
      keep_idx <- if (length(rem)) setdiff(seq_len(n), rem) else seq_len(n)
      category[keep_idx] <- ifelse(ra$exact_sp, "Exact duplicate",
                            ifelse(ra$partial_sp, "Partial overlap", "No overlap"))
    }

    if (!is.null(ra) && length(rem)) {
      add_features(proxy, disp[rem, , drop = FALSE],
                   rep("Removed", length(rem)), faded = TRUE, group = "removed")
    }
    add_features(proxy, disp[keep_idx, , drop = FALSE], category[keep_idx],
                 group = "features")

    # Overlap status legend: shown on the first Calculate and every redraw after.
    proxy |> addLegend(
      layerId = "legend", position = "bottomright",
      colors = unname(PAL), labels = names(PAL),
      title = "Overlap status", opacity = 1
    )

    # fit on the raw view and right after Calculate; keep the user's zoom after a fix
    if (is.null(ra)) {
      bb <- as.numeric(st_bbox(disp))
      if (all(is.finite(bb))) proxy |> fitBounds(bb[1], bb[2], bb[3], bb[4])
    }
  })

  # --- table row click: outline that Overlap_id group and zoom to it ---
  observeEvent(input$ov_attr_group_click, {
    rb <- ov_vals$before
    req(rb)
    gid   <- suppressWarnings(as.integer(input$ov_attr_group_click))
    proxy <- leafletProxy("ov_map")
    proxy |> clearGroup("highlight")
    if (is.na(gid)) return()

    feats <- which(rb$group_id == gid)
    if (!length(feats)) return()
    d <- st_transform(rb$x[feats, , drop = FALSE], 4326)
    d <- d[!st_is_empty(d), , drop = FALSE]
    if (nrow(d) == 0) return()

    if (any(grepl("LINESTRING", as.character(st_geometry_type(d))))) {
      proxy |> addPolylines(data = d, group = "highlight",
                            color = "#00e5ff", weight = 6, opacity = 1)
    } else {
      proxy |> addPolygons(data = d, group = "highlight",
                           color = "#00e5ff", weight = 4, opacity = 1, fill = FALSE)
    }
    bb <- as.numeric(st_bbox(d))
    if (all(is.finite(bb))) {
      proxy |> fitBounds(bb[1], bb[2], bb[3], bb[4],
                         options = list(padding = c(40, 40), maxZoom = 18))
    }
  })

  # --- save: original features minus the removed ones ------------------
  output$ov_save <- downloadHandler(
    filename = function() {
      stub <- if (is.null(input$gpkg)) "layer"
              else tools::file_path_sans_ext(input$gpkg$name)
      paste0(stub, "_overlaps_fixed.gpkg")
    },
    content = function(file) {
      req(ov_vals$src)
      x <- ov_vals$src
      if (length(ov_vals$removed)) x <- x[-ov_vals$removed, ]
      lyr <- if (is.null(input$ov_layer)) "layer" else paste0(input$ov_layer, "_fixed")
      tmp <- tempfile(fileext = ".gpkg")
      st_write(x, tmp, layer = lyr, quiet = TRUE)
      file.copy(tmp, file, overwrite = TRUE)
    }
  )
}

shinyApp(ui, server)