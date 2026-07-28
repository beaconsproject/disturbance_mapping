library(sf)
library(DT)
library(dplyr)
library(markdown)
library(leaflet)
library(summarytools)
library(bslib)

# Increase upload limit
options(shiny.maxRequestSize = 1000 * 1024^2)

# Load reference data
# types  <- readr::read_csv('www/yg_industry_disturbance_types.csv') # REMOVED AS REQUESTED
google <- "https://mts1.google.com/vt/lyrs=s&hl=en&src=app&x={x}&y={y}&z={z}&s=G"

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
"),
  
  # JS handler to set grids_in_gpkg input from server
  tags$head(tags$script(HTML('
    Shiny.addCustomMessageHandler("setGridsInGpkg", function(val) {
      Shiny.setInputValue("gridsInGpkg", val);
    });
  '))),
  
  # 1. VIEW FEATURES TAB
  nav_panel(
    title = "View Features",
    icon  = icon("upload"),
    layout_sidebar(
      sidebar = sidebar(width=280,
        navset_tab(
          
          # -- UPLOAD TAB ------------------------------------------------------
          nav_panel(
            title = "Upload",
            
            br(),
            markdown("**1. UPLOAD DATA**"),
            fileInput("gpkg", "Geopackage:", accept = ".gpkg"),
            hr(),
            
            markdown("**2. SELECT LAYERS**"),
            selectInput("bnd",  "Study area:",          choices = NULL),
            selectInput("line", "Linear disturbances:", choices = NULL),
            selectInput("poly",      "Areal disturbances:",  choices = NULL),
            selectInput("grid2x2",   "Grid 2x2 km:",         choices = NULL),
            selectInput("grid10x10", "Grid 10x10 km:",       choices = NULL),
            hr(),
            
            markdown("**3. VIEW DISTURBANCES**"),
            actionButton("mapButton", "Map features", class = "btn-primary w-100"),
            conditionalPanel(
              condition = "input.mapButton > 0 && !input.gridsInGpkg",
              hr(),
              markdown("**4. SELECT GRIDS**"),
              checkboxGroupInput(
                "gridLayers",
                label    = "Intersecting grids to display:",
                choices  = c("Grid 2x2km" = "grid_2x2", "Grid 10x10km" = "grid_10x10"),
                selected = "grid_2x2"
              ),
              actionButton("gridButton", "Load grids", icon = icon("th"), class = "btn-secondary w-100")
            )
          ),
          
          # -- EDIT TAB --------------------------------------------------------
          nav_panel(
            title = "Edit",
            
            br(),
            markdown("**4. EDIT ATTRIBUTES**"),
            p(class = "text-muted small",
              "Click any cell in the Linear or Areal attribute panels to edit its value."),
            actionButton("saveEdits", "Save edits",
                         icon  = icon("floppy-disk"),
                         class = "btn-warning w-100"),
            downloadButton("downloadGpkg", "Save as new geopackage",
                           icon  = icon("download"),
                           class = "btn-success w-100")
          ),
          
          # -- SEARCH TAB ------------------------------------------------------
          nav_panel(
            title = "Search",
            
            br(),
            markdown("**SEARCH FEATURES**"),
            
            # 1) Choose layer
            radioButtons(
              "searchLayer",
              label = "Select layer:",
              choices = c(
                "Linear disturbances" = "linear",
                "Areal disturbances"  = "areal"
              ),
              selected = "linear"
            ),
            
            # 2) Choose feature ID (populated reactively)
            selectInput(
              "searchFeatureId",
              label = "Select feature:",
              choices  = NULL,
              selected = NULL
            ),
            
            # 3) Zoom button
            actionButton(
              "zoomToFeature",
              label = "Zoom to feature",
              icon  = icon("crosshairs"),
              class = "btn-primary w-100"
            )
          )
        )
      ),
      
      layout_columns(
        col_widths = c(9, 3),
        
        # Left: map + full attribute tables
        navset_card_tab(
          height      = 750,
          full_screen = TRUE,
          nav_panel("Overview",        includeMarkdown("www/overview.md")),
          nav_panel("Mapview",         leafletOutput("map", height = "100%")),
          nav_panel("Linear features", DTOutput("table_line")),
          nav_panel("Areal features",  DTOutput("table_poly")),
          nav_panel("Dataset requirements", includeMarkdown("www/dataset_requirements.md"))
        ),
        
        # Right: scale box + per-feature attribute cards
        layout_columns(
          col_widths = 12,
          value_box(
            title = "Viewing Scale",
            value = textOutput("scaleText"),
            showcase = icon("magnifying-glass-plus"),
            theme = "primary"
          ),
          navset_card_tab(
            height      = 300,
            full_screen = TRUE,
            nav_panel("Linear attributes", DTOutput("table1")),
            nav_panel("Areal attributes",  DTOutput("table2"))
          ),
          navset_card_tab(
            height      = 300,
            full_screen = TRUE,
            nav_panel("Grid 10x10 km", DTOutput("table_grid10")),
            nav_panel("Grid 2x2 km",   DTOutput("table_grid2"))
          )
        )
      )
    )
  ),
  
  # 2. VALIDATE ATTRIBUTES TAB
  nav_panel(
    title = "Validate Attributes",
    icon  = icon("check-circle"),
    layout_sidebar(
      sidebar = sidebar(width=280,
        title = "Validation",
        fileInput("csv", "Upload attributes (CSV):", accept = ".csv"),
        #selectInput("fld",  "Select attribute:",          choices = NULL),
        #hr(),
        actionButton("valButton", "Validate attributes", class = "btn-success w-100")
      ),
      navset_card_tab(
        full_screen = TRUE,
        nav_panel("Linear summary", verbatimTextOutput("linearText")),
        nav_panel("Linear errors",  DTOutput("linearTable")),
        nav_panel("Areal summary",  verbatimTextOutput("arealText")),
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
    
    # Grid layers: populate with matching layer names if present, else empty
    grid2_choices  <- if ("grid_2x2km"   %in% lyrs) c("grid_2x2km"   = "grid_2x2km")   else c("(not in file)" = "")
    grid10_choices <- if ("grid_10x10km" %in% lyrs) c("grid_10x10km" = "grid_10x10km") else c("(not in file)" = "")
    updateSelectInput(session, "grid2x2",   choices = grid2_choices)
    updateSelectInput(session, "grid10x10", choices = grid10_choices)
    
    # Tell the UI whether grids are already present (hides section 4 if TRUE)
    grids_present <- all(c("grid_2x2km", "grid_10x10km") %in% lyrs)
    session$sendCustomMessage("setGridsInGpkg", grids_present)
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
  
  # --- Detect whether both grids are embedded in the uploaded gpkg ------------
  grids_in_gpkg <- reactive({
    req(input$gpkg)
    lyrs <- st_layers(input$gpkg$datapath)$name
    all(c("grid_2x2km", "grid_10x10km") %in% lyrs)
  })

  # Unified trigger: fires on mapButton (when grids are in gpkg) OR gridButton
  grid_trigger <- reactive({
    list(input$mapButton, input$gridButton)
  })

  # --- Grid Selection: from gpkg on mapButton, or external file on gridButton -
  grid_2x2 <- eventReactive(grid_trigger(), {
    req(bnd())
    # When grids are embedded: load on mapButton; otherwise require gridButton
    if (isTRUE(grids_in_gpkg())) {
      req(input$mapButton > 0)
    } else {
      req(input$gridButton > 0, "grid_2x2" %in% input$gridLayers)
    }
    bnd_proj  <- st_transform(bnd(), 3578)
    gpkg_src  <- if (!is.null(input$grid2x2) && nzchar(input$grid2x2)) {
      list(path = input$gpkg$datapath, layer = input$grid2x2)
    } else {
      list(path = "www/sbfi_grid.gpkg", layer = "grid_2x2km")
    }
    full_grid <- st_read(gpkg_src$path, layer = gpkg_src$layer, quiet = TRUE)
    full_grid <- st_transform(full_grid, 3578)
    sel       <- full_grid[bnd_proj, ]
    st_transform(sel, 4326)
  })

  grid_10x10 <- eventReactive(grid_trigger(), {
    req(bnd())
    if (isTRUE(grids_in_gpkg())) {
      req(input$mapButton > 0)
    } else {
      req(input$gridButton > 0, "grid_10x10" %in% input$gridLayers)
    }
    bnd_proj  <- st_transform(bnd(), 3578)
    gpkg_src  <- if (!is.null(input$grid10x10) && nzchar(input$grid10x10)) {
      list(path = input$gpkg$datapath, layer = input$grid10x10)
    } else {
      list(path = "www/sbfi_grid.gpkg", layer = "grid_10x10km")
    }
    full_grid <- st_read(gpkg_src$path, layer = gpkg_src$layer, quiet = TRUE)
    full_grid <- st_transform(full_grid, 3578)
    sel       <- full_grid[bnd_proj, ]
    st_transform(sel, 4326)
  })

  # Track whether grids have been loaded (via either button)
  grids_loaded <- reactiveVal(FALSE)
  observeEvent(input$gridButton, { grids_loaded(TRUE) })
  observeEvent(input$mapButton, {
    if (isTRUE(grids_in_gpkg())) grids_loaded(TRUE)
  })

  # --- Scale Calculation ------------------------------------------------------
  output$scaleText <- renderText({
    req(input$map_zoom, input$map_center)
    zoom <- input$map_zoom
    lat  <- input$map_center$lat
    res <- (cos(lat * pi / 180) * 40075016.686) / (256 * 2^zoom)
    scale_val <- round(res * 3779.53)
    paste0("1:", format(scale_val, big.mark = ","))
  })
  
  # --- Editable attribute tables ----------------------------------------------
  line_attrs       <- reactiveVal(NULL)
  poly_attrs       <- reactiveVal(NULL)
  grid2_attrs      <- reactiveVal(NULL)
  grid10_attrs     <- reactiveVal(NULL)
  
  observeEvent(line_base(), { line_attrs(st_drop_geometry(line_base())) })
  observeEvent(poly_base(), { poly_attrs(st_drop_geometry(poly_base())) })
  observeEvent(grid_2x2(),   { grid2_attrs(st_drop_geometry(grid_2x2()))   })
  observeEvent(grid_10x10(), { grid10_attrs(st_drop_geometry(grid_10x10())) })
  
  selected_line_id   <- reactiveVal(NULL)
  selected_poly_id   <- reactiveVal(NULL)
  selected_grid2_id  <- reactiveVal(NULL)
  selected_grid10_id <- reactiveVal(NULL)
  
  # --- Populate Search feature IDs when layer or data changes ----------------
  observe({
    req(input$searchLayer)
    if (input$searchLayer == "linear") {
      ids <- if (!is.null(line_attrs())) line_attrs()$line_id else character(0)
      updateSelectInput(session, "searchFeatureId",
                        label   = "Select line_id:",
                        choices = ids)
    } else {
      ids <- if (!is.null(poly_attrs())) poly_attrs()$poly_id else character(0)
      updateSelectInput(session, "searchFeatureId",
                        label   = "Select poly_id:",
                        choices = ids)
    }
  })
  
  # --- Zoom to selected feature -----------------------------------------------
  observeEvent(input$zoomToFeature, {
    req(input$searchFeatureId)
    
    if (input$searchLayer == "linear") {
      req(line_base())
      feat <- line_base() |> filter(line_id == input$searchFeatureId)
      req(nrow(feat) > 0)
      bbox <- st_bbox(feat)
      leafletProxy("map") |>
        fitBounds(
          lng1 = bbox[["xmin"]], lat1 = bbox[["ymin"]],
          lng2 = bbox[["xmax"]], lat2 = bbox[["ymax"]]
        )
      selected_line_id(input$searchFeatureId)
      
    } else {
      req(poly_base())
      feat <- poly_base() |> filter(poly_id == input$searchFeatureId)
      req(nrow(feat) > 0)
      bbox <- st_bbox(feat)
      leafletProxy("map") |>
        fitBounds(
          lng1 = bbox[["xmin"]], lat1 = bbox[["ymin"]],
          lng2 = bbox[["xmax"]], lat2 = bbox[["ymax"]]
        )
      selected_poly_id(input$searchFeatureId)
    }
  })
  
  # --- Map --------------------------------------------------------------------
  output$map <- renderLeaflet({
    m <- leaflet(options = leafletOptions(attributionControl = FALSE)) |>
      addTiles(google, group = "Google.Imagery") |>
      addProviderTiles("Esri.WorldTopoMap", group = "Esri.WorldTopoMap") |>
      addProviderTiles("Esri.WorldImagery", group = "Esri.WorldImagery") |>
      addScaleBar(position = 'bottomleft')
    
    if (!is.null(input$gpkg) && input$mapButton > 0) {
      overlay_groups <- c("Study area", "Areal disturbances", "Linear disturbances")
      m <- m |>
        addPolygons(data = bnd(), fill = FALSE, weight = 2, color = 'blue',
                    group = "Study area") |>
        addPolygons(data = poly_base(), fill = TRUE, weight = 1, color = 'red',
                    fillOpacity = 0.5, layerId = poly_base()$poly_id,
                    group = "Areal disturbances") |>
        addPolylines(data = line_base(), weight = 2, color = 'red',
                     layerId = line_base()$line_id,
                     group = "Linear disturbances")

      # If both grids are embedded in the gpkg, draw them immediately
      if (isTRUE(grids_in_gpkg())) {
        g2_cols  <- grid_fill_colors(grid2_attrs())
        g10_cols <- grid_fill_colors(grid10_attrs())
        m <- m |>
          addPolygons(data = grid_2x2(), fill = TRUE, weight = 1,
                      color = '#555555', fillColor = g2_cols, group = "Grid 2x2km",
                      fillOpacity = 0.45, layerId = paste0("G2_", seq_len(nrow(grid_2x2())))) |>
          addPolygons(data = grid_10x10(), fill = TRUE, weight = 2,
                      color = '#222222', fillColor = g10_cols, group = "Grid 10x10km",
                      fillOpacity = 0.45, layerId = paste0("G10_", seq_len(nrow(grid_10x10())))) |>
          addLegend(position = "bottomright",
                    colors   = c("#555555", "#222222", "#FFD700"),
                    labels   = c("Grid 2x2km", "Grid 10x10km", "status = 1"),
                    layerId  = "gridLegend")
        overlay_groups <- c(overlay_groups, "Grid 2x2km", "Grid 10x10km")
      }

      m <- m |>
        addLayersControl(
          position      = "topright",
          baseGroups    = c("Esri.WorldTopoMap", "Esri.WorldImagery", "Google.Imagery"),
          overlayGroups = overlay_groups,
          options       = layersControlOptions(collapsed = FALSE)
        )
    } else {
      m <- m |>
        addLayersControl(
          position   = "topright",
          baseGroups = c("Esri.WorldTopoMap", "Esri.WorldImagery", "Google.Imagery"),
          options    = layersControlOptions(collapsed = FALSE)
        )
    }
    m
  })
  
  # --- Add grids to map via proxy when gridButton is clicked ------------------
  observeEvent(input$gridButton, {
    req(bnd())
    
    proxy <- leafletProxy("map")
    
    # Clear any previously added grid layers and legend
    proxy |>
      clearGroup("Grid 2x2km") |>
      clearGroup("Grid 10x10km") |>
      removeControl("gridLegend")
    
    legend_colors <- c()
    legend_labels <- c()
    overlay_groups <- c("Study area", "Areal disturbances", "Linear disturbances")
    
    if ("grid_2x2" %in% input$gridLayers && !is.null(grid_2x2())) {
      g2_cols <- grid_fill_colors(grid2_attrs())
      proxy <- proxy |>
        addPolygons(data = grid_2x2(), fill = TRUE, weight = 1,
                    color = '#555555', fillColor = g2_cols, group = "Grid 2x2km",
                    fillOpacity = 0.45, layerId = paste0("G2_", seq_len(nrow(grid_2x2()))))
      legend_colors <- c(legend_colors, "#555555")
      legend_labels <- c(legend_labels, "Grid 2x2km")
      overlay_groups <- c(overlay_groups, "Grid 2x2km")
    }
    
    if ("grid_10x10" %in% input$gridLayers && !is.null(grid_10x10())) {
      g10_cols <- grid_fill_colors(grid10_attrs())
      proxy <- proxy |>
        addPolygons(data = grid_10x10(), fill = TRUE, weight = 2,
                    color = '#222222', fillColor = g10_cols, group = "Grid 10x10km",
                    fillOpacity = 0.45, layerId = paste0("G10_", seq_len(nrow(grid_10x10()))))
      legend_colors <- c(legend_colors, "#222222")
      legend_labels <- c(legend_labels, "Grid 10x10km")
      overlay_groups <- c(overlay_groups, "Grid 10x10km")
    }
    
    if (length(legend_colors) > 0) {
      proxy <- proxy |>
        addLegend(position = "bottomright",
                  colors   = c(legend_colors, "#FFD700"),
                  labels   = c(legend_labels, "status = 1"),
                  layerId  = "gridLegend")
    }
    
    proxy |>
      addLayersControl(
        position      = "topright",
        baseGroups    = c("Esri.WorldTopoMap", "Esri.WorldImagery", "Google.Imagery"),
        overlayGroups = overlay_groups,
        options       = layersControlOptions(collapsed = FALSE)
      )
  })
  
  # --- Full feature tables ----------------------------------------------------
  saved_line_attrs <- reactiveVal(NULL)
  saved_poly_attrs <- reactiveVal(NULL)
  
  observeEvent(line_attrs(), { saved_line_attrs(line_attrs()) }, once = TRUE)
  observeEvent(poly_attrs(), { saved_poly_attrs(poly_attrs()) }, once = TRUE)
  
  output$table_line <- renderDT({
    req(saved_line_attrs())
    datatable(saved_line_attrs(), rownames = FALSE,
              options = list(dom = 'tip', pageLength = 15))
  })
  
  output$table_poly <- renderDT({
    req(saved_poly_attrs())
    datatable(saved_poly_attrs(), rownames = FALSE,
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
    else if (grepl("^G2_", id)) selected_grid2_id(id)
    else if (grepl("^G10_",id)) selected_grid10_id(id)
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
  
  output$table_grid2 <- renderDT({
    req(selected_grid2_id(), grid2_attrs())
    idx <- as.integer(sub("^G2_", "", selected_grid2_id()))
    req(!is.na(idx), idx >= 1L, idx <= nrow(grid2_attrs()))
    render_editable(grid2_attrs()[idx, , drop = FALSE])
  })

  output$table_grid10 <- renderDT({
    req(selected_grid10_id(), grid10_attrs())
    idx <- as.integer(sub("^G10_", "", selected_grid10_id()))
    req(!is.na(idx), idx >= 1L, idx <= nrow(grid10_attrs()))
    render_editable(grid10_attrs()[idx, , drop = FALSE])
  })

  observeEvent(input$table2_cell_edit, {
    req(poly_attrs(), selected_poly_id())
    apply_edit(poly_attrs, selected_poly_id, "poly_id", input$table2_cell_edit)
  })
  
  # Edit helper for grid tables (keyed by numeric row index, not an ID column)
  apply_grid_edit <- function(attrs, selected_id, prefix, info) {
    df        <- attrs()
    row_idx   <- as.integer(sub(paste0("^", prefix), "", selected_id()))
    attr_name <- names(df)[info$row]
    new_val   <- tryCatch(
      methods::as(info$value, class(df[[attr_name]])[1]),
      error = function(e) info$value
    )
    df[row_idx, attr_name] <- new_val
    attrs(df)
  }
  
  observeEvent(input$table_grid2_cell_edit, {
    req(grid2_attrs(), selected_grid2_id())
    apply_grid_edit(grid2_attrs, selected_grid2_id, "G2_", input$table_grid2_cell_edit)
  })
  
  observeEvent(input$table_grid10_cell_edit, {
    req(grid10_attrs(), selected_grid10_id())
    apply_grid_edit(grid10_attrs, selected_grid10_id, "G10_", input$table_grid10_cell_edit)
  })
  
  # --- Helper: derive fill colour from status column --------------------------
  grid_fill_colors <- function(attrs_df) {
    if (!is.null(attrs_df) && "status" %in% names(attrs_df)) {
      ifelse(as.character(attrs_df$status) == "1", "#FFD700", "#AAAAAA")
    } else {
      rep("#AAAAAA", if (is.null(attrs_df)) 0L else nrow(attrs_df))
    }
  }
  
  # --- Redraw Grid 2x2 polygons when attrs change -----------------------------
  observeEvent(grid2_attrs(), {
    req(grid_2x2(), grids_loaded())
    g2  <- grid_2x2()
    df  <- grid2_attrs()
    req(nrow(g2) == nrow(df))
    cols <- grid_fill_colors(df)
    leafletProxy("map") |>
      clearGroup("Grid 2x2km") |>
      addPolygons(
        data        = g2,
        fill        = TRUE,
        weight      = 1,
        color       = '#555555',
        fillColor   = cols,
        fillOpacity = 0.45,
        group       = "Grid 2x2km",
        layerId     = paste0("G2_", seq_len(nrow(g2)))
      )
  }, ignoreNULL = TRUE, ignoreInit = TRUE)
  
  # --- Redraw Grid 10x10 polygons when attrs change ---------------------------
  observeEvent(grid10_attrs(), {
    req(grid_10x10(), grids_loaded())
    g10 <- grid_10x10()
    df  <- grid10_attrs()
    req(nrow(g10) == nrow(df))
    cols <- grid_fill_colors(df)
    leafletProxy("map") |>
      clearGroup("Grid 10x10km") |>
      addPolygons(
        data        = g10,
        fill        = TRUE,
        weight      = 2,
        color       = '#222222',
        fillColor   = cols,
        fillOpacity = 0.45,
        group       = "Grid 10x10km",
        layerId     = paste0("G10_", seq_len(nrow(g10)))
      )
  }, ignoreNULL = TRUE, ignoreInit = TRUE)
  
  saved_grid2_attrs  <- reactiveVal(NULL)
  saved_grid10_attrs <- reactiveVal(NULL)
  
  observeEvent(grid2_attrs(),  { saved_grid2_attrs(grid2_attrs())   })
  observeEvent(grid10_attrs(), { saved_grid10_attrs(grid10_attrs()) })
  
  observeEvent(input$saveEdits, {
    req(line_attrs(), poly_attrs())
    saved_line_attrs(line_attrs())
    saved_poly_attrs(poly_attrs())
    if (!is.null(grid2_attrs()))  saved_grid2_attrs(grid2_attrs())
    if (!is.null(grid10_attrs())) saved_grid10_attrs(grid10_attrs())
    showNotification("Edits saved to tables.", type = "message", duration = 3)
  })
  
  output$downloadGpkg <- downloadHandler(
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
      # Write grids with edited attributes if available
      g2_sf  <- tryCatch(grid_2x2(),   error = function(e) NULL)
      g10_sf <- tryCatch(grid_10x10(), error = function(e) NULL)
      if (!is.null(g2_sf)) {
        if (!is.null(saved_grid2_attrs()))
          g2_sf <- st_sf(saved_grid2_attrs(), geometry = st_geometry(g2_sf))
        st_write(g2_sf,  dsn = file, layer = "grid_2x2km",   driver = "GPKG", append = TRUE, quiet = TRUE)
      }
      if (!is.null(g10_sf)) {
        if (!is.null(saved_grid10_attrs()))
          g10_sf <- st_sf(saved_grid10_attrs(), geometry = st_geometry(g10_sf))
        st_write(g10_sf, dsn = file, layer = "grid_10x10km", driver = "GPKG", append = TRUE, quiet = TRUE)
      }
      for (lyr in setdiff(all_lyrs, edited_lyrs)) {
        other_sf <- tryCatch(st_read(src_path, lyr, quiet = TRUE), error = function(e) NULL)
        if (!is.null(other_sf)) st_write(other_sf, dsn = file, layer = lyr, driver = "GPKG", append = TRUE, quiet = TRUE)
      }
    }
  )
  
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
  
  val_line <- eventReactive(input$valButton, { req(saved_line_attrs()); validate_df(saved_line_attrs(), 'Linear') })
  val_poly <- eventReactive(input$valButton, { req(saved_poly_attrs()); validate_df(saved_poly_attrs(), 'Areal') })
  
  output$linearTable <- renderDT({
    req(val_line())
    val_line() |> filter(industry_test != 'ok' | disturbance_test != 'ok' | combination_test != 'ok') |> datatable()
  })
  
  output$linearText <- renderPrint({
    req(val_line(), input$gpkg)
    df <- saved_line_attrs()
    cat('Project: ', input$gpkg$name, '\nDate: ',  format(Sys.time(), "%d %B %Y"), '\n\n# LINEAR DISTURBANCES\n')
    for (i in names(df)) { cat('\n## Attribute: ', toupper(i), '\n'); print(dfSummary(df[i], graph.col = FALSE, max.distinct.values = 20)) }
  })
  
  output$arealTable <- renderDT({
    req(val_poly())
    val_poly() |> filter(industry_test != 'ok' | disturbance_test != 'ok' | combination_test != 'ok') |> datatable()
  })
  
  output$arealText <- renderPrint({
    req(val_poly(), input$gpkg)
    df <- saved_poly_attrs()
    cat('Project: ', input$gpkg$name, '\nDate: ',  format(Sys.time(), "%d %B %Y"), '\n\n# AREAL DISTURBANCES\n')
    for (i in names(df)) { cat('\n## Attribute: ', toupper(i), '\n'); print(dfSummary(df[i], graph.col = FALSE, max.distinct.values = 20)) }
  })
}

shinyApp(ui, server)