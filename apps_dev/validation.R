library(sf)
library(DT)
library(tmap)
library(leaflet)
library(tidyverse)
library(shinydashboard)

bnd <- st_read('../data/fda_10ab.gpkg', 'fda', quiet=T) %>% st_zm(drop=T)
Linear = st_read('../data/fda_10ab.gpkg', 'linear_features+', quiet=T)
Areal = st_read('../data/fda_10ab.gpkg', 'areal_features+', quiet=T)
tmap_mode("view")
tmap_options(check.and.fix = TRUE)
tmap_options(basemaps = c(Esri.WorldImagery="Esri.WorldImagery", Esri.NatGeoWorldMap="Esri.NatGeoWorldMap"))

ui = dashboardPage(
  dashboardHeader(title = "Disturbance Validation"),
  dashboardSidebar(
    sidebarMenu(
        menuItem("View disturbances", tabName = "fri", icon = icon("th"))
    ),
    selectInput("inv", label = "Feature type:", choices = c("Areal","Linear")),
    checkboxInput("dist","Add all disturbances", value=T),
    hr(),
    actionButton("goButton", "Select (random) polygon")
  ),
  dashboardBody(
    tabItems(
        tabItem(tabName="fri",
            fluidRow(
                #box(title = "FRI Map", leafletOutput("map1", height=800), width=8),
                tabBox(
                    id = "one", width="8",
                    tabPanel("Polygon", leafletOutput("map1", height=700))#,
                    #tabPanel("Summary", pre(includeText("bc10.txt")))
                ),
                tabBox(
                    id = "two", width="4",
                    tabPanel("Attributes", DT::dataTableOutput("tab1", height=700))
                )
            )
        )
    )
  )
)

server = function(input, output) {

    n <- eventReactive(input$goButton, {
        if (input$inv=="Linear") {
            n = sample_n(Linear, 1)
        } else if (input$inv=="Areal") {
            n = sample_n(Areal, 1)
        }
    })

    output$map1 <- renderLeaflet({
        if (input$goButton) {
            if (input$inv=="Areal") {
                m = tm_shape(n()) + tm_borders(col='yellow', lwd=2, group="Random feature")
            } else {
                n = st_cast(n(), "LINESTRING")
                m = tm_shape(n) + tm_lines(col='yellow', lwd=2, group="Random feature")
            }
            if (input$dist) {
                #m = m + tm_shape(Areal) + tm_borders(col='red', lwd=2, group="Areal disturbances") +
                m = m + tm_shape(Areal) + tm_fill(col='red', alpha=0.5, group="Areal disturbances") +
                        tm_shape(Linear) + tm_lines(col='red', lwd=1, group="Linear disturbances")
                #m %>% tmap_leaflet() %>% leaflet::hideGroup(c("Areal disturbances","Linear disturbances"))
            }
        } else {
            if (input$inv=="Areal") {
                m = tm_shape(bnd) + tm_borders(col='green', lwd=2, group="Boundary") + 
                    tm_shape(Areal) + tm_fill(col='red', alpha=0.5, group="Areal disturbances") +
                    tm_shape(Linear) + tm_lines(col='yellow', alpha=1, group="Linear disturbances")
            } else {
                m = tm_shape(bnd) + tm_borders(col='green', lwd=2, group="Boundary") + 
                    tm_shape(Areal) + tm_fill(col='red', alpha=0.5, group="Areal disturbances") +
                    tm_shape(Linear) + tm_lines(col='yellow', alpha=1, group="Linear disturbances")
            }
        }       
        #m %>% tmap_leaflet() %>% leaflet::hideGroup(c("Areal disturbances","Linear disturbances"))
        lf <- tmap_leaflet(m)
        lf %>% leaflet::hideGroup(c("Areal disturbances","Linear disturbances"))
    })

    dta1 <- reactive({
        x1 = st_drop_geometry(n())
        x2 = as_tibble(x1) %>% slice(1) %>% unlist(., use.names=FALSE)
        x = bind_cols(Attribute=names(x1), Value=x2)
    })

	output$tab1 <- DT::renderDataTable({
        x = dta1() #%>% filter(!Attribute %in% casVars)
		datatable(x, rownames=F, options=list(dom = 'tip', scrollX = TRUE, scrollY = TRUE, pageLength = 25), class="compact")
    })

}
shinyApp(ui, server)