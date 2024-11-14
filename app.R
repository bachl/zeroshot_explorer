# app.R
library(shiny)
library(shinythemes)
library(httr2)
library(jsonlite)
library(tidyverse)

# Source ui.R and server.R here
source("ui.R")
source("server.R")

shinyApp(ui = ui, server = server)
