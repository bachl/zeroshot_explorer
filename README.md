# zeroshot_explorer
 A simple shiny app to explore the behavior of zeroshot classification using an OpenAI model.


Copy the following code into a new R script and run it to start the shiny app:

```r
if (!require("shiny")) install.packages("shiny")
if (!require("shinythemes")) install.packages("shinythemes")
if (!require("httr2")) install.packages("httr2")
if (!require("jsonlite")) install.packages("jsonlite")
if (!require("tidyverse")) install.packages("tidyverse")
shiny::runGitHub("zeroshot_explorer", "bachl")
```
