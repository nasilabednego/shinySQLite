---
title: "shinySQLite"
author: "ABEDNEGO NASILA"
date: '2022-07-29'
output: html_document
editor_options: 
  markdown: 
    wrap: 72
---

# shinySQLite

shinySQLite enables you to create, edit, use and share SQLite databases
directly from shiny app. To install the package from GitHub, run
`devtools::install_github('nasilabednego/shinySQLite')`

You can use the demo app to build and manage your custom databases. Run
the following code in R to get started.

`shinySQLite::runshinySQLite(dbname = '')`

Enter any name as your dbname. Any time you call the dbname you once
created, you will find your activities stored in the same db. With
shinySQLite, you can also build new databases at any time.
