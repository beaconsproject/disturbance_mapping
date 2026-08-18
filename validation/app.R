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
}

shinyApp(ui, server)