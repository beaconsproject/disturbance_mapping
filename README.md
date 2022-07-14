# Regional disturbance and intactness mapping


## Workflow


## Case studies


## Shiny app

The shiny app enables regional conservation planners in the boreal region to explore the effects of changing assumptions about the effects of disturbances on resulting human footprint and intactness maps. To run the app from a local machine:

  1. Install R (download from r-project.org and follow instructions)
  2. Install the following additional packages:

    install.packages(c("sf","dplyr","leaflet","shinydashboard"))

  3. Start the Shiny app:

    library(shiny)
    runGitHub("beaconsproject/dc-mapping", subdir="")
