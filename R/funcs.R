
runshinySQLite<-function(){
library(shiny)
library(RSQLite)
library(tidyverse)
library(DT)
library(shinyjs)
library(bslib)
library(shinyWidgets)
library(dashboardthemes)
library(bs4Dash)


mydb<-data.frame(dbname='',created.on='')
con <- dbConnect(SQLite(), "myrsqltdbfile")
dbWriteTable(con, "awesome", mydb, append = TRUE)
dbBegin(con)
rs <- dbSendStatement(con, paste("DELETE from awesome WHERE dbname = '' "))
dbGetRowsAffected(rs)
dbClearResult(rs)


dbCommit(con)

dbDisconnect(con)




ui <-fluidPage(theme = bs_theme(version = '4',
                                bootswatch = 'mat'),
               theme_blue_gradient,
               useShinyjs(),
               titlePanel('shinySQLitedb'),
               tabsetPanel(
                 ########################################--- edit db append rows ui items----
                 tabPanel('Open or Create New db',
                          sidebarLayout(

                            sidebarPanel(
                              uiOutput('opendb'),hr(),

                              'OR CREATE A NEW DB ',
                              uiOutput('creatdbui')

                            ),
                            mainPanel(
                              uiOutput('checkdb'),
                              tableOutput('dt'),
                              hr(),
                              tags$b('These are your available databases. You can open any of them in the select input and edit them in the'),span(tags$b('Edit db'),style='color:blue'),tags$b('tab'),
                              dataTableOutput('myavailabledbs')
                            ))
                 ),
                 ########################################---.
                 tabPanel('Edit db',

                          tabsetPanel(
                            ########################################--- edit db append rows ui items----
                            tabPanel('Edit Rows',
                                     tabsetPanel(
                                     tabPanel('Add Rows',
                                     sidebarLayout(
                                       sidebarPanel(
                                         uiOutput('selected'),
                                         uiOutput('valuestoappend')

                                       ),
                                       mainPanel(
                                         'This is the row you are likely to append to the db',
                                         tableOutput('reactdf'),hr(),
                                         'Your append values will display here when you check in the sidebar',
                                         tableOutput('appendeddb')
                                       ))
                            ),

                            tabPanel('Delete rows',
                                     sidebarLayout(
                                       sidebarPanel(
                                         uiOutput('checktodel')
                                       ),
                                       mainPanel(
                                         tableOutput('rowreduceddt')
                                       )
                                     )
                            )
                            )),
                            ########################################---.

                            ########################################--- edit db cells ui items----
                            tabPanel('Edit Cells',
                                     sidebarLayout(
                                       sidebarPanel(
                                         uiOutput('editincol'),

                                         uiOutput('conditcol'),
                                         uiOutput('conditvalue'),


                                       ),
                                       mainPanel(
                                         tableOutput('editedcells')
                                       )
                                     )
                            ),
                            ########################################---.

                            ########################################--- db add colums ui items----
                            tabPanel('Edit Columns',
                                     tabsetPanel(
                                       tabPanel('Add Columns',
                                                sidebarLayout(
                                                  sidebarPanel(
                                                    uiOutput('addcolsui')
                                                  ),
                                                  mainPanel(
                                                    tableOutput('dbaddedcolstable')
                                                  ))
                                       ),
                                       tabPanel('Change Column Name',
                                                sidebarLayout(
                                                  sidebarPanel(
                                                    uiOutput('selectclm')
                                                  ),
                                                  mainPanel(
                                                    tableOutput('changedcoltable')
                                                  ))
                                       )
                                     ))
                          ))
                 ########################################---.

               )
)



server <- function(input, output, session) {

  dbtbl<-reactive({
    con <- dbConnect(SQLite(), "myrsqltdbfile")
    if(
      input$createnew==T){

      mydb<-data.frame(COLUMN1='',COLUMN2='')

      dbWriteTable(con, input$addnewdb, mydb, append = TRUE)

    }



    data <- dbReadTable(con, input$addnewdb)

    #dbDisconnect(con)
    return(data)
  })

  output$dt<-renderTable({
    if(input$createnew==T
    ){
      dbtbl()[1,]}
  })





  output$checkdb<-renderUI({
    if(input$createnew==T
    ){
      HTML(
        paste('You have just created',span(style='color:fucshsia',input$addnewdb),'db. To open it, type its name in the select input above'))}
  })


  output$opendb<-renderUI({

    read<-awesomedt()
    choices<-read$dbname
    fluidPage(
      selectInput('opened',uiOutput('opnddb'),choices = choices)
    )
  })

  output$opnddb<-renderUI({
    if(
      input$opened!=''){
      HTML(
        paste(span(style='color:green','You have opened '),span(style='color:blue',input$opened),'db.', span(style='color:green','You can open your other dbs here or CREATE MORE DBs more below')))}else
          span(style='color:orange','Select to open your database here')

  })

  output$checkcontrol<-renderUI({
    if(input$createnew==F){
      'check to create'}else{
        span(style='color:green','Success! Your new db is created. You can uncheck now')
      }
  })

  output$editdbname<-renderUI({
    if(input$createnew==F){
      textInput('addnewdb',placeholder = 'type a new db name here','')}else{

      }
  })


  output$creatdbui<-renderUI({
    fluidPage(
      uiOutput('editdbname'),
      checkboxInput('createnew',uiOutput('checkcontrol'),value = F)
    )
  })



  awesomedt<-reactive({
    con<-dbConnect(con,"myrsqltdbfile")
    if(input$createnew==T){

      dbWriteTable(con, "awesome", data.frame(dbname=input$addnewdb,created.on=paste(Sys.time())), append = TRUE)

      dbBegin(con)
      rs <- dbSendStatement(con, paste("DELETE from awesome WHERE dbname = '' "))
      dbGetRowsAffected(rs)
      dbClearResult(rs)


      dbCommit(con)


    }
    data <- dbReadTable(con, "awesome")
    #dbDisconnect(con)
    return(data)
  })


  output$myavailabledbs<-renderDataTable({
    awesomedt()%>%
      datatable(.,
                extensions = 'Buttons',
                options = list(
                  lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                  pageLength = 10,
                  dom = 'Blfrtip',
                  buttons = list(
                    list(
                      extend = "print",
                      text='print',
                      title ='DISPATCH OF FINAL SIGNED CONTRACTS 2022 FOR HEALTHCARE PROVIDER REGISTRY 12/01/2022'
                    )
                  )
                ),
                class = 'strips'
      )
  })









  ########################################--- edit db append rows server fun----
  output$selected<-renderUI({
    con <- dbConnect(SQLite(), "myrsqltdbfile")
    if(input$opened==''){"You have not opened any database. First open any of your dbs or create one if you don't have. Click on Open or Create New db to perform the action."}else{
      req(input$opened%in%awesomedt()[,1]==T)
      myda <- dbReadTable(con, input$opened)
      selectInput('column',label = 'filter column',choices = names(myda))}
  })

  output$valuestoappend<-renderUI({
    if(input$opened==''){}else{
      fluidPage(
        textInput('value', 'Type the entry you want to append'),
        checkboxInput('commit', label = 'commit changes', value = F))}})

  mydatareactive<-reactive({
    replcol<-which(names(mydata)==input$column)
    mydata[,replcol]=input$value
    return(mydata)
  })

  mydatareactive<-reactive({
    con <- dbConnect(SQLite(), "myrsqltdbfile")
    mydat <- dbReadTable(con, input$opened)
    myda<-mydat[1,]
    myda[]=''
    replcol<-which(names(myda)==input$column)
    myda[,replcol]=input$value
    return(myda)
  })

  output$reactdf<-renderTable({
    if(input$opened!=''){
      mydatareactive()}
  })




  # Append mydatareactive to dataframe

  mynewdb<-reactive({
    con <- dbConnect(SQLite(), "myrsqltdbfile")
    if(input$opened!=''){
      if(input$commit==T){

        dbWriteTable(con, input$opened, mydatareactive(), append = TRUE)}}
    data <- dbReadTable(con, input$opened)
    #dbDisconnect(con)
    return(data)
  })


  output$appendeddb<-renderTable({
    if(input$opened!=''){
      mynewdb()}
  })
  ########################################---.


  ########################################--- edit db cells server fun----
  output$editincol<-renderUI({
    con <- dbConnect(SQLite(), "myrsqltdbfile")
    if(input$opened==''){"You have not opened any database. First open any of your dbs or create one if you don't have. Click on Open or Create New db to perform the action."}else{
      myda <- dbReadTable(con, input$opened)
      fluidPage(
        selectInput('col',label = 'edit cell in this column',choices = names(myda)),
        textInput('changes', '', placeholder =
                    paste('my edit','|', 'Just type anything to add')),hr())}
    # select the column to filter
  })


  output$conditcol<-renderUI({
    con <- dbConnect(SQLite(), "myrsqltdbfile")
    if(input$opened==''){}else{
      myda <- dbReadTable(con, input$opened)
      selectInput('myfilter',label = 'filter column to condition',choices = names(myda))# select the column to filter
    }})

  quotedchanges<-reactive({
    paste0("'",input$changes,"'")
  })

  quotedcond<-reactive({
    paste0("'",input$mycond,"'")
  })

  output$cuo<-renderText({
    y=cuod()
    return(y)
  })

  output$conditvalue<-renderUI({
    if(input$opened==''){}else{
      myda <- mynewdb()
      x <- myda %>% select(!!sym(input$myfilter))
      fluidPage(
        selectInput("mycond", HTML(paste("Select column codition where",span(input$myfilter,style='color:red'),'=',uiOutput('kll'))), choices = c('choose condition here',x), selected = ''),
        checkboxInput('commitchanges', label = 'commit changes', value = F)
      )}
  })


  output$kll<-renderUI(
    {span(input$mycond,style='color:fuchsia')}
  )

  dbeditcells <- reactive({
    con <- dbConnect(SQLite(), "myrsqltdbfile")
    if(input$commitchanges==T){

      dbBegin(con)

      dbSendStatement(con, paste("UPDATE", input$opened,
                                 "SET", input$col, "=", quotedchanges(),
                                 "WHERE", input$myfilter, " =", quotedcond()))
      dbCommit(con)

    }

    data <- dbReadTable(con, input$opened)
    #dbDisconnect(con)
    return(data)

  })

  output$editedcells<-renderTable({
    if(input$opened!=''){
      if(input$commitchanges==T){
        dbeditcells()}}
  })
  ########################################---.


  ########################################--- db add columns----


  output$addcolsui<-renderUI({
    if(input$opened==''){"You have not opened any database. First open any of your dbs or create one if you don't have. Click on Open or Create New db to perform the action."}else{
      fluidPage(
        textInput('addcol',
                  placeholder = 'type the column name you would like to add',label = ''),
        checkboxInput('confirm',value = F,'commit changes')
      )}
  })




  dbaddedcol <- reactive({
    con <- dbConnect(SQLite(), "myrsqltdbfile")
    if(input$confirm==T){

      dbBegin(con)
      dbSendStatement(con, paste("
                           ALTER TABLE", input$opened,
                           "ADD COLUMN", input$addcol, "text;empty"))

      dbCommit(con)}

    data <- dbReadTable(con, input$opened)
    #dbDisconnect(comy)
    return(data)
  })


  output$dbaddedcolstable<-renderTable({
    if(input$opened!=''){
      dbaddedcol()}
  })

  ########################################---.



  ########################################--- change column names----

  output$selectclm<-renderUI({
    con <- dbConnect(SQLite(), "myrsqltdbfile")
    cols<-dbReadTable(con, input$opened)
    choics<-names(cols)
    fluidPage(
      selectInput("selectedcol","select the column you want to change it's name",choices=choics),
      textInput('newname',placeholder='type the new name here',''),
      checkboxInput('makechanges','commit changes',value=F)

    )

  })



  changecolname <- reactive({
    con <- dbConnect(SQLite(), "myrsqltdbfile")
    if(input$makechanges==T){

      dbBegin(con)
      dbSendStatement(con, paste("
                           ALTER TABLE", input$opened,
                           "RENAME COLUMN", input$selectedcol,"TO", paste0(input$newname,";")))

      dbCommit(con)}

    data <- dbReadTable(con, input$opened)
    #dbDisconnect(comy)
    return(data)
  })


  output$changedcoltable<-renderTable({
    if(input$opened!=''){
      changecolname()}
  })


  ########################################---.


  ########################################--- delete add rows----

  output$checktodel<-renderUI({

    fluidPage(

      actionBttn('dlt','DELETE ROW',style = 'fil',size = 'sm',color = 'da'))
  })

  output$COLcondui <- renderUI({
    con <- dbConnect(SQLite(), dbname="myrsqltdbfile")
    dl<-dbReadTable(con,input$opened)
    x <- dl %>% select(!!sym(input$del))
    selectInput("condt", "enter the column codition to delete row(s)", choices = c("''",x), selected = x[1])
  })


  rowremove <- reactive({

    con <- dbConnect(SQLite(), dbname="myrsqltdbfile")

    if(input$myconfirmation1==T){

      dbBegin(con)
      rs <- dbSendStatement(con, paste("DELETE from", input$opened, "WHERE",input$del, input$bool,paste0("'",input$condt,"'" )))
      dbGetRowsAffected(rs)
      dbClearResult(rs)


      dbCommit(con)}

    data <- dbReadTable(con, input$opened)
    #dbDisconnect(comy)
    return(data)
  })


  observeEvent(input$dlt, {
    con <- dbConnect(SQLite(), dbname="myrsqltdbfile")
    dr<-dbReadTable(con,input$opened)
    ask_confirmation(
      inputId = "myconfirmation1",
      type = "danger",

      text=fluidPage(
        selectInput('del','','filter column ',choices = names(dr)),
        selectInput('bool','Boolean operator',choices = c('=','>','<')),
        uiOutput('COLcondui'),
        paste('Do you really want to delete',input$del, 'from the db?')
      )
    )
  })

  observeEvent(input$myconfirmation1,{
    con <- dbConnect(SQLite(), dbname="myrsqltdbfile")
    output$rowreduceddt<-renderTable(
      {dr <- dbReadTable(con, input$opened)
      rowremove()
      }
    )})
  ########################################---.
}

# Run the application
shinyApp(ui = ui, server = server)}


