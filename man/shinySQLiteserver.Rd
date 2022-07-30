\name{shinySQLiteserver}
\alias{shinySQLiteserver}
\title{Add shinySQLiteUI() in shiny app ui and shinySQLiteserver(dbname='', input=input, output=output, session=session)}
\usage{
  #In ui
shinySQLiteUI()
  #In server
shinySQLiteserver(dbname='', input=input, output=output, session=session)
}
\description{
Add shinySQLite elements to your shiny app
}
\examples{
library(shiny)
library(shinySQLite)
ui <- fluidPage(
)
server <- function(input, output, session){
  }
shinyApp(ui = ui, server =server)
}
