26 September, 2021

-   [Required Packages](#required-packages)

# Required Packages

In this project, we will use a number of amazing R packages:

-   `knitr`: to generate pretty tables of date using the `kable()`
    function.  
-   `tidyverse`: to manipulate data, generate plots (via `ggplot2`), and
    to use piping/chaining.  
-   `rmarkdown`: to knit output files manually using the `render()`
    function.  
-   `jsonlite`: to pull data from various endpoints of the Covid 19
    APIs.

``` r
#get results of five countries to compare
compareCountries <- function(country1, country2, country3=NULL, country4=NULL, country5=NULL){
  covid <- GET("https://api.covid19api.com/summary")
  covidDF <- fromJSON(rawToChar(covid$content))
  data <- covidDF$Countries %>% as_tibble()
  #checks if first country supplied is in the data, misspelled or lack quotation marks
  if (country1 %in% data$Country){
    output1 <- data %>% filter(data$Country == country1) %>% select(-c(ID,Slug, Premium))
  }
  else{
    message <- paste("ERROR: Check spelling of first country or use quotation marks.")
    stop(message)
  }
  #checks if second country supplied is in the data, misspelled or lack quotation marks
  if (country2 %in% data$Country){
    output2 <- data %>% filter(data$Country == country2) %>% select(-c(ID,Slug, Premium))
  }
  else{
    message <- paste("ERROR: Check spelling of second country or use quotation marks.")
    stop(message)
  }
  #checks if third country supplied is in the data, misspelled or lack quotation marks
  if (country3 %in% data$Country){
  output3 <- data %>% filter(data$Country == country3) %>% select(-c(ID,Slug, Premium))
  }
  else{
    message <- paste("ERROR: Check spelling of third country or use quotation marks.")
    stop(message)
    }
  #checks if fourth country supplied is in the data, misspelled or lack quotation marks  
  if (country4 %in% data$Country){
  output4 <- data %>% filter(data$Country == country4) %>% select(-c(ID,Slug, Premium))
  }
  else{
    message <- paste("ERROR: Check spelling of fourth country or  use quotation marks.")
    stop(message)
  }
  #checks if fifth country supplied is in the data, misspelled or lack quotation marks  
  if (country5 %in% data$Country){
  output5 <- data %>% filter(data$Country == country5) %>% select(-c(ID,Slug, Premium))
  }
  else{
    message <- paste("ERROR: Check spelling of fifth country or use quotation marks.")
    stop(message)
  }
  output <- rbind(output1, output2, output3, output4, output5)
  return(output)
}

#check function if it works
compareCountries("Philippines","Indonesia", "Albania", "China", "Malaysia")
```

    ## # A tibble: 5 x 9
    ##   Country    CountryCode NewConfirmed TotalConfirmed NewDeaths TotalDeaths NewRecovered TotalRecovered Date              
    ##   <chr>      <chr>              <int>          <int>     <int>       <int>        <int>          <int> <chr>             
    ## 1 Philippin… PH                     0        2470175         0       37405            0              0 2021-09-26T22:23:…
    ## 2 Indonesia  ID                     0        4206253         0      141381            0              0 2021-09-26T22:23:…
    ## 3 Albania    AL                     0         167354         0        2629            0              0 2021-09-26T22:23:…
    ## 4 China      CN                    39         108266         0        4849            0              0 2021-09-26T22:23:…
    ## 5 Malaysia   MY                 13899        2185131       228       25159            0              0 2021-09-26T22:23:…
