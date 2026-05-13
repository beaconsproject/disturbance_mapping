library(sf)
library(DT)
library(dplyr)
library(leaflet)
library(summarytools)
library(bslib)

# Increase upload limit
options(shiny.maxRequestSize = 100 * 1024^2)

# Load reference data
types  <- readr::read_csv('www/yg_industry_disturbance_types.csv')
errors <- readr::read_csv('www/yg_industry_disturbance_types_errors.csv')
spot   <- "https://mapservices.gov.yk.ca/imagery/rest/services/Satellites/Satellites_MedRes_Update/ImageServer"
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
  
  # 1. INTRODUCTION TAB
  nav_panel(
    title = "Introduction",
    icon  = icon("info-circle"),
    navset_card_tab(
      full_screen = TRUE,
      nav_panel("Overview",               includeMarkdown("www/overview.md")),
      nav_panel("Permitted disturbances", DTOutput("types"))
    )
  ),
  
  # 2. VIEW FEATURES TAB
  nav_panel(
    title = "View features",
    icon  = icon("upload"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Data Controls",
        
        markdown("**1. UPLOAD DATA**"),
        fileInput("gpkg", "Geopackage:", accept = ".gpkg"),
        hr(),
        
        markdown("**2. SELECT LAYERS**"),
        selectInput("bnd",  "Study area:",          choices = NULL),
        selectInput("line", "Linear disturbances:", choices = NULL),
        selectInput("poly", "Areal disturbances:",  choices = NULL),
        hr(),
        
        markdown("**3. VIEW DISTURBANCES**"),
        actionButton("mapButton", "Map features", class = "btn-primary w-100"),
        hr(),
        
        markdown("**4. EDIT ATTRIBUTES**"),
        p(class = "text-muted small",
          "Click any cell in the Linear or Areal attribute panels to edit its value."),
        actionButton("saveEdits", "Save edits",
                     icon  = icon("floppy-disk"),
                     class = "btn-warning w-100"),
        br(), br(),
        downloadButton("downloadGpkg", "Save as new geopackage",
                       icon  = icon("download"),
                       class = "btn-success w-100")
      ),
      
      layout_columns(
        col_widths = c(8, 4),
        
        # Left: map + full attribute tables
        navset_card_tab(
          height      = 750,
          full_screen = TRUE,
          nav_panel("Mapview",         leafletOutput("map", height = "100%")),
          nav_panel("Linear features", DTOutput("table_line")),
          nav_panel("Area features",   DTOutput("table_poly"))
        ),
        
        # Right: per-feature attribute cards (editable)
        layout_columns(
          col_widths = 12,
          card(
            height      = 375,
            full_screen = TRUE,
            card_header("Linear attributes"),
            DTOutput("table1")
          ),
          card(
            height      = 375,
            full_screen = TRUE,
            card_header("Areal attributes"),
            DTOutput("table2")
          )
        )
      )
    )
  ),
  
  # 3. VALIDATE ATTRIBUTES TAB
  nav_panel(
    title = "Validate Attributes",
    icon  = icon("check-circle"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Validation",
        actionButton("valButton", "Run validation code", class = "btn-success w-100")
      ),
      navset_card_tab(
        full_screen = TRUE,
        nav_panel("Linear summary", verbatimTextOutput("linearText")),
        nav_panel("Linear errors",  DTOutput("linearTable")),
        nav_panel("Areal summary",  verbatimTextOutput("arealText")),
        nav_panel("Areal errors",   DTOutput("arealTable"))
      )
    )
  )
)

# ==============================================================================
# SERVER
# ==============================================================================

server <- function(input, output, session) {
  
  # --- Reference table --------------------------------------------------------
  output$types <- renderDataTable({
    datatable(types, rownames = FALSE,
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
  
  # --- Base spatial reactives (loaded once on "Map features") ----------------
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
  
  # --- Editable attribute tables (reactiveVal = mutable) ---------------------
  # Only attribute columns are stored here; geometry lives in *_base().
  line_attrs <- reactiveVal(NULL)
  poly_attrs <- reactiveVal(NULL)
  
  observeEvent(line_base(), { line_attrs(st_drop_geometry(line_base())) })
  observeEvent(poly_base(), { poly_attrs(st_drop_geometry(poly_base())) })
  
  # --- Track selected feature ------------------------------------------------
  selected_line_id <- reactiveVal(NULL)
  selected_poly_id <- reactiveVal(NULL)
  
  # --- Map -------------------------------------------------------------------
  output$map <- renderLeaflet({
    m <- leaflet(options = leafletOptions(attributionControl = FALSE)) |>
      addTiles(google, group = "Google.Imagery") |>
      addProviderTiles("Esri.WorldTopoMap", group = "Esri.WorldTopoMap") |>
      addProviderTiles("Esri.WorldImagery", group = "Esri.WorldImagery") |>
      addScaleBar(position = 'bottomleft')
    
    if (!is.null(input$gpkg) && input$mapButton > 0) {
      m <- m |>
        addPolygons(data = bnd(), fill = FALSE, weight = 2, color = 'blue',
                    group = "Study area") |>
        addPolygons(data = poly_base(), fill = TRUE, weight = 1, color = 'red',
                    fillOpacity = 0.5, layerId = poly_base()$poly_id,
                    group = "Areal disturbances") |>
        addPolylines(data = line_base(), weight = 2, color = 'red',
                     layerId = line_base()$line_id,
                     group = "Linear disturbances") |>
        addLayersControl(
          position      = "topright",
          baseGroups    = c("Esri.WorldTopoMap", "Esri.WorldImagery", "Google.Imagery"),
          overlayGroups = c("Study area", "Areal disturbances", "Linear disturbances"),
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
  
  # --- Full feature tables (reactive to live edits after Save) ---------------
  # Use a flag so table_line/table_poly reflect edits only after Save is clicked.
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
  
  # --- Per-feature editable attribute panels ---------------------------------
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
  
  # --- Map click: select a feature -------------------------------------------
  observeEvent(input$map_shape_click, {
    id <- input$map_shape_click$id
    req(id)
    if (grepl("^P", id)) selected_poly_id(id)
    else if (grepl("^L", id)) selected_line_id(id)
  })
  
  # --- Apply cell edits to live attribute stores -----------------------------
  apply_edit <- function(attrs, selected_id, id_col, info) {
    df        <- attrs()
    row_match <- df[[id_col]] == selected_id()
    # Transposed table: row index maps to attribute name
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
  
  # --- Save edits button: flush live attrs to the full tables ----------------
  observeEvent(input$saveEdits, {
    req(line_attrs(), poly_attrs())
    saved_line_attrs(line_attrs())
    saved_poly_attrs(poly_attrs())
    showNotification("Edits saved to tables.", type = "message", duration = 3)
  })
  
  # --- Save as new geopackage ------------------------------------------------
  # downloadButton in the UI calls this handler directly; no JS tricks needed.
  # The filename function explicitly ends in .gpkg so browsers cannot
  # substitute another extension.
  output$downloadGpkg <- downloadHandler(
    filename = function() {
      paste0("disturbance_edited_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".gpkg")
    },
    content = function(file) {
      req(input$gpkg, line_base(), poly_base(), line_attrs(), poly_attrs())
      
      src_path    <- input$gpkg$datapath
      all_lyrs    <- st_layers(src_path)$name
      edited_lyrs <- c(input$line, input$poly)
      
      # Recombine edited attributes with original geometries
      line_sf <- st_sf(
        line_attrs() |> select(-line_id),
        geometry = st_geometry(line_base())
      )
      poly_sf <- st_sf(
        poly_attrs() |> select(-poly_id),
        geometry = st_geometry(poly_base())
      )
      
      # Write edited layers (first layer creates the file)
      st_write(line_sf, dsn = file, layer = input$line,
               driver = "GPKG", quiet = TRUE)
      st_write(poly_sf, dsn = file, layer = input$poly,
               driver = "GPKG", append = TRUE, quiet = TRUE)
      
      # Append all other layers from the source unchanged
      for (lyr in setdiff(all_lyrs, edited_lyrs)) {
        other_sf <- tryCatch(
          st_read(src_path, lyr, quiet = TRUE),
          error = function(e) NULL
        )
        if (!is.null(other_sf)) {
          st_write(other_sf, dsn = file, layer = lyr,
                   driver = "GPKG", append = TRUE, quiet = TRUE)
        }
      }
    }
  )
  
  # =============================================================================
  # VALIDATION  --  operates on the live (saved) attribute tables, not the
  # original file, so any edits made before clicking "Run validation code"
  # are reflected in the results.
  # =============================================================================
  
  # Helper: compute validation columns for a data frame
  validate_df <- function(df, feature_type) {
    indu  <- types |> filter(TYPE_FEATURE == feature_type) |> pull(TYPE_INDUSTRY)   |> unique()
    dist  <- types |> filter(TYPE_FEATURE == feature_type) |> pull(TYPE_DISTURBANCE)|> unique()
    combo <- types |> filter(TYPE_FEATURE == feature_type) |>
      mutate(C = paste0(TYPE_INDUSTRY, "***", TYPE_DISTURBANCE)) |> pull(C) |> unique()
    
    df |>
      mutate(
        industry_test    = ifelse(TYPE_INDUSTRY    %in% indu,  'ok', 'please fix'),
        disturbance_test = ifelse(TYPE_DISTURBANCE %in% dist,  'ok', 'please fix'),
        combination_test = ifelse(
          paste0(TYPE_INDUSTRY, "***", TYPE_DISTURBANCE) %in% combo, 'ok', 'not expected'
        )
      )
  }
  
  # Validation uses saved_line_attrs / saved_poly_attrs so that "Save edits"
  # must be clicked before validation reflects edits (intentional workflow).
  val_line <- eventReactive(input$valButton, {
    req(saved_line_attrs())
    validate_df(saved_line_attrs(), 'Linear')
  })
  
  val_poly <- eventReactive(input$valButton, {
    req(saved_poly_attrs())
    validate_df(saved_poly_attrs(), 'Areal')
  })
  
  output$linearTable <- renderDT({
    req(val_line())
    val_line() |>
      filter(industry_test != 'ok' | disturbance_test != 'ok' | combination_test != 'ok') |>
      datatable()
  })
  
  output$linearText <- renderPrint({
    req(val_line(), input$gpkg)
    df <- saved_line_attrs()
    cat('Project: ', input$gpkg$name,
        '\nDate: ',  format(Sys.time(), "%d %B %Y"),
        '\n\n# LINEAR DISTURBANCES\n')
    for (i in names(df)) {
      cat('\n## Attribute: ', toupper(i), '\n')
      print(dfSummary(df[i], graph.col = FALSE, max.distinct.values = 20))
    }
  })
  
  output$arealTable <- renderDT({
    req(val_poly())
    val_poly() |>
      filter(industry_test != 'ok' | disturbance_test != 'ok' | combination_test != 'ok') |>
      datatable()
  })
  
  output$arealText <- renderPrint({
    req(val_poly(), input$gpkg)
    df <- saved_poly_attrs()
    cat('Project: ', input$gpkg$name,
        '\nDate: ',  format(Sys.time(), "%d %B %Y"),
        '\n\n# AREAL DISTURBANCES\n')
    for (i in names(df)) {
      cat('\n## Attribute: ', toupper(i), '\n')
      print(dfSummary(df[i], graph.col = FALSE, max.distinct.values = 20))
    }
  })
}

shinyApp(ui, server)