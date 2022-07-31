---
title: "shinySQLite"
author: "ABEDNEGO NASILA"
date: '2022-07-29'
output: html_document
---

# shinySQLite

shinySQLite enables you to create, upload, edit, use, store and share data frames in SQLite databases
directly from shiny app. To install the package from GitHub run;
```devtools::install_github('nasilabednego/shinySQLite')```
## Add shinySQLite to your shiny app!
```
library (shiny)
library(shinySQLite) 
# you can run together with your custom functions 
ui <- fluidPage(
 ...
 shinySQLiteUI()
 ...
)
server <- function(input, output, session){
 shinySQLiteserver(dbname = 'anydbname', input = input, output = output, session = session)
 ...
}
shinyApp(ui = ui, server = server)
```
You can use the demo app to build and manage your custom databases. Run
the following code in R to get started.
```shinySQLite::runshinySQLite(dbname = '')```
Enter any name as your dbname. Any time you call the dbname you once
created, you will find your activities stored in the same db. With
shinySQLite, you can build new databases, manipulate and save your data frames in them at any time.
