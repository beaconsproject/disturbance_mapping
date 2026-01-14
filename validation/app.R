library(sf)
library(DT)
library(dplyr)
library(leaflet)
library(leaflet.esri) # devtools::install_github("bhaskarvk/leaflet.esri")
library(summarytools)
library(shinydashboard)
options(shiny.maxRequestSize=100*1024^2) 

types <- readr::read_csv('www/yg_industry_disturbance_types.csv')
errors <- readr::read_csv('www/yg_industry_disturbance_types_errors.csv')
spot = "https://mapservices.gov.yk.ca/imagery/rest/services/Satellites/Satellites_MedRes_Update/ImageServer"
google = "https://mts1.google.com/vt/lyrs=s&hl=en&src=app&x={x}&y={y}&z={z}&s=G"

ui = dashboardPage(skin = "green",
  dashboardHeader(title = "Disturbance Validation"),
  dashboardSidebar(
    sidebarMenu(id="tabs",
      menuItem("Introduction", tabName="intro", icon=icon("th")),
      menuItem("Upload data", tabName = "get", icon = icon("th")),
      menuItem("Validate attributes", tabName = "val", icon = icon("th"))
    ),
    conditionalPanel(
      condition="input.tabs=='get'",
      hr(),
      HTML("&nbsp;&nbsp; 1. UPLOAD DATA"),
      fileInput("gpkg", "Geopackage:", accept=".gpkg"),
      HTML("&nbsp;&nbsp; 2. SELECT LAYERS"),
      selectInput("bnd", "Study area:", choices = NULL),
      selectInput("line", "Linear disturbances:", choices = NULL),
      selectInput("poly", "Areal disturbances:", choices = NULL),
      br(),
      HTML("&nbsp;&nbsp; 3. VIEW DISTURBANCES"),
      actionButton("mapButton", "Map features")
    ),
    conditionalPanel(
      condition="input.tabs=='val'",
      hr(), 
      HTML("&nbsp;&nbsp; VALIDATE ATTRIBUTES"),
      actionButton("valButton", "Run validation code")
    )
    ),

  dashboardBody(
    tabItems(
      tabItem(tabName="intro",
            fluidRow(
                tabBox(id = "one", width="12",
                    tabPanel("Overview", includeMarkdown("www/overview.md")),
                    tabPanel("Permitted disturbances", DTOutput("types"))
                )
            )
        ),
        tabItem(tabName="get",
            fluidRow(
                tabBox(
                    id = "one", width="8",
                    tabPanel("Mapview", leafletOutput("map", height=750)),
                    tabPanel("Linear features", DTOutput("table_line", height=750)),
                    tabPanel("Area features", DTOutput("table_poly", height=750))
                ),
                tabBox(
                    id = "two", width="4",
                    tabPanel("Linear attributes", DTOutput("table1", height=750)),
                    tabPanel("Areal attributes", DTOutput("table2", height=750))
              )
            )
        ),
        tabItem(tabName="val",
            fluidRow(
                tabBox(
                    id = "one", width="12",
                    tabPanel("Linear summary", verbatimTextOutput("linearText")),
                    tabPanel("Linear errors", DTOutput("linearTable")),
                    tabPanel("Areal summary", verbatimTextOutput("arealText")),
                    tabPanel("Areal errors", DTOutput("arealTable"))
          )
        )
      )
    )
  )
)

server = function(input, output, session) {

  output$types <- renderDataTable({
    datatable(types, rownames=F, options=list(dom = 'tip', scrollX = TRUE, scrollY = TRUE, pageLength = 25), class="compact")
  })

  observeEvent(input$gpkg, {
    file <- input$gpkg$datapath
    gpkg <- st_read(file)
    lyrs <- st_layers(file)$name
    updateSelectInput(session, "layer", choices = lyrs)
    updateSelectInput(session, "bnd", choices=lyrs, selected='studyarea')
    updateSelectInput(session, "line", choices=lyrs, selected='linear_disturbance')
    updateSelectInput(session, "poly", choices=lyrs, selected='areal_disturbance')
  })

  ##############################################################################
  # Upload AOI layers
  ##############################################################################
  bnd <- eventReactive(input$gpkg, {
    req(input$mapButton)
    file <- input$gpkg$datapath
    ext <- tools::file_ext(file)
    if(ext == "gpkg"){
      aoi <- st_read(file, input$bnd) %>% st_transform(4326)
    } else {
      showNotification("Wrong file type, must be geopackage (.gpkg)", type = "error")
    }
  })

  line <- eventReactive(input$gpkg, {
    req(input$mapButton)
    file <- input$gpkg$datapath
    ext <- tools::file_ext(file)
    if(ext == "gpkg"){
      aoi <- st_read(file, input$line) %>% st_transform(4326)
      aoi <- mutate(aoi, line_id=paste0('L',1:nrow(aoi)))
    } else {
      showNotification("Wrong file type, must be geopackage (.gpkg)", type = "error")
    }
  })

  poly <- eventReactive(input$gpkg, {
    req(input$mapButton)
    file <- input$gpkg$datapath
    ext <- tools::file_ext(file)
    if(ext == "gpkg"){
      aoi <- st_read(file, input$poly) %>% st_transform(4326)
      aoi <- mutate(aoi, poly_id=paste0('P',1:nrow(aoi)))
    } else {
      showNotification("Wrong file type, must be geopackage (.gpkg)", type = "error")
    }
  })

  ##############################################################################
  # View initial set of maps
  ##############################################################################
  output$map <- renderLeaflet({
    m <- leaflet(options = leafletOptions(attributionControl=FALSE)) %>%
      addTiles(google, group="Google.Imagery") %>%
      addEsriImageMapLayer(url=spot, group="SPOT.Imagery") %>%
      addProviderTiles("Esri.WorldTopoMap", group="Esri.WorldTopoMap") %>%
      addProviderTiles("Esri.WorldImagery", group="Esri.WorldImagery") %>%
      addScaleBar(position='bottomleft') #%>%
      if (is.null(input$gpkg)) {
        m <- m %>% 
          addLayersControl(position = "topright",
            baseGroups=c("Esri.WorldTopoMap","Esri.WorldImagery","Google.Imagery","SPOT.Imagery"),
            options = layersControlOptions(collapsed = F))
      } else {
        req(input$mapButton)
        m <- m %>% addPolygons(data=bnd(), fill=F, weight=2, color='blue', group="Study area") %>%
          addPolygons(data=poly(), fill=T, weight=1, color='red', fillOpacity=0.5, layerId=poly()$poly_id, group="Areal disturbances") %>%
          addPolylines(data=line(), weight=2, color='red', fillOpacity=1, layerId=line()$line_id, group="Linear disturbances") %>%
          #addPolygons(data=grd(), color="grey", weight=1, fill=F, group="Grid") %>%
          addLayersControl(position = "topright",
            baseGroups=c("Esri.WorldTopoMap","Esri.WorldImagery","Google.Imagery","SPOT.Imagery"),
            overlayGroups = c("Study area","Areal disturbances","Linear disturbances"),
            options = layersControlOptions(collapsed = F)) #%>%
          #hideGroup(c("Study area","Areal disturbances","Linear disturbances"))
      }
    m
  })

  output$table_line <- renderDT({
    x <- line() %>% st_drop_geometry()
    datatable(x, rownames=F, options=list(dom = 'tip', scrollX = TRUE, scrollY = TRUE, pageLength = 15), class="compact")
  })

  output$table_poly <- renderDT({
    x <- poly() %>% st_drop_geometry()
    datatable(x, rownames=F, options=list(dom = 'tip', scrollX = TRUE, scrollY = TRUE, pageLength = 15), class="compact")
  })

  ##############################################################################
  # Click on a linear or areal feature and display attributes
  ##############################################################################
  observeEvent(input$map_shape_click, {

    # Capture the info of the clicked feature
    click <- input$map_shape_click

    selected <- filter(poly(), poly_id==click$id) %>%
      st_drop_geometry()

    #if click id isn't null render the table
    if(!is.null(click$id)) {
      output$table2 = renderDT({
        xt <- t(selected)
        datatable(xt, rownames=T, options=list(dom = 'tip', scrollX = TRUE, scrollY = TRUE, pageLength = 20), class="compact")
      }) 
    } 
  }) 

  observeEvent(input$map_shape_click, {

    # Capture the info of the clicked feature
    click <- input$map_shape_click

    selected <- filter(line(), line_id==click$id) %>%
      st_drop_geometry()

    #if click id isn't null render the table
    if(!is.null(click$id)) {
      output$table1 = renderDT({
        xt <- t(selected)
        datatable(xt, rownames=T, options=list(dom = 'tip', scrollX = TRUE, scrollY = TRUE, pageLength = 20), class="compact")
      }) 
    } 
  }) 

  ##############################################################################
  # Validate attributes
  ##############################################################################

  output$linearTable <- renderDT({
    req(input$valButton)
    x_line <- st_read(input$gpkg$datapath, input$line, quiet=TRUE) |>
      st_drop_geometry()
    line_indu <- types |>
      filter(TYPE_FEATURE=='Linear') |>
      select(TYPE_INDUSTRY) |>
      unique() |>
      pull()
    line_dist <- types |>
      filter(TYPE_FEATURE=='Linear') |>
      select(TYPE_DISTURBANCE) |>
      unique() |>
      pull()
    # These are combinations that are theoretically not permitted but left as is for now
    line_combo <- types |>
      filter(TYPE_FEATURE=='Linear') |>
      select(TYPE_INDUSTRY, TYPE_DISTURBANCE) |>
      mutate(TYPE_COMBINED=paste0(TYPE_INDUSTRY,"***",TYPE_DISTURBANCE)) |>
      unique() |>
      pull()
    # These ones need to be fixed asap - they cannot occur (see fixit script)
    line_combo_error <- errors |>
      filter(TYPE_FEATURE=='Linear') |>
      select(TYPE_INDUSTRY_error, TYPE_DISTURBANCE_error) |>
      mutate(TYPE_COMBINED_error=paste0(TYPE_INDUSTRY_error,"***",TYPE_DISTURBANCE_error)) |>
      unique() |>
      pull()
    x_line_test = mutate(x_line, 
      industry_test=ifelse(TYPE_INDUSTRY %in% line_indu, 'ok', 'please fix'),
      disturbance_test=ifelse(TYPE_DISTURBANCE %in% line_dist, 'ok', 'please fix'),
      combination_test=ifelse(paste0(TYPE_INDUSTRY,"***",TYPE_DISTURBANCE) %in% line_combo, 'ok', 'not expected')) |>
      select(TYPE_INDUSTRY, industry_test, TYPE_DISTURBANCE, disturbance_test, combination_test) |>
      filter(industry_test=='please fix' | disturbance_test=='please fix' | combination_test=='not expected')
    datatable(x_line_test)
  })

  output$arealTable <- renderDT({
    req(input$valButton)
    x_poly <- st_read(input$gpkg$datapath, input$poly, quiet=TRUE) |>
      st_drop_geometry()
    poly_indu <- types |>
      filter(TYPE_FEATURE=='Areal') |>
      select(TYPE_INDUSTRY) |>
      unique() |>
      pull()
    poly_dist <- types |>
      filter(TYPE_FEATURE=='Areal') |>
      select(TYPE_DISTURBANCE) |>
      unique() |>
      pull()
    # These are combinations that are theoretically not permitted but left as is for now
    poly_combo <- types |>
      filter(TYPE_FEATURE=='Areal') |>
      select(TYPE_INDUSTRY, TYPE_DISTURBANCE) |>
      mutate(TYPE_COMBINED=paste0(TYPE_INDUSTRY,"***",TYPE_DISTURBANCE)) |>
      unique() |>
      pull()
    x_poly_test = mutate(x_poly, 
      industry_test=ifelse(TYPE_INDUSTRY %in% poly_indu, 'ok', 'please fix'),
      disturbance_test=ifelse(TYPE_DISTURBANCE %in% poly_dist, 'ok', 'please fix'),
      combination_test=ifelse(paste0(TYPE_INDUSTRY,"***",TYPE_DISTURBANCE) %in% poly_combo, 'ok', 'not expected')) |>
      select(TYPE_INDUSTRY, industry_test, TYPE_DISTURBANCE, disturbance_test, combination_test) |>
      filter(industry_test=='please fix' | disturbance_test=='please fix' | combination_test=='not expected')
    #readr::write_csv(x_poly_test, paste0(output_dir, '/areal_types_validation.csv'))
    datatable(x_poly_test)
  })

  output$linearText <- renderPrint({
    req(input$valButton)
    x_line <- st_read(input$gpkg$datapath, input$line, quiet=TRUE) |>
      st_drop_geometry()
    line_vars <- names(x_line)
    cat('Project: ', input$gpkg$datapath, '\n', sep="")
    cat('Date: ', format(Sys.time(), "%d %B %Y"),'\n', sep="")
    cat('\n\n# LINEAR DISTURBANCES\n', sep="")
    for (i in line_vars) {
      cat('\n## Attribute: ',toupper(i),'\n\n', sep="")
      print(dfSummary(x_line[i], graph.col=FALSE, max.distinct.values=20))
    }
  })

  output$arealText <- renderPrint({
    req(input$valButton)
    x_poly <- st_read(input$gpkg$datapath, input$poly, quiet=TRUE) |>
      st_drop_geometry()
    poly_vars <- names(x_poly)
    cat('Project: ', input$gpkg$datapath, '\n', sep="")
    cat('Date: ', format(Sys.time(), "%d %B %Y"),'\n', sep="")
    cat('\n\n# AREAL DISTURBANCES\n', sep="")
    for (i in poly_vars) {
      cat('\n## Attribute: ',toupper(i),'\n\n', sep="")
      print(dfSummary(x_poly[i], graph.col=FALSE, max.distinct.values=20))
    }
  })

  #session$onSessionEnded(function() {
  #  stopApp()
  #})

}
shinyApp(ui, server)