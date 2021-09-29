28 September, 2021

-   [Required Packages](#required-packages)
-   [Data Manipulation](#data-manipulation)

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
#helper function to generate a vector of countries and their corresponding Slug name whose data are update daily.

countryList <- function(){
  covid <- GET("https://api.covid19api.com/summary")
  covidDF <- fromJSON(rawToChar(covid$content))
  countryList <- covidDF$Countries %>% select(Country, Slug) %>% as_tibble()
  return(countryList)
}
  
countryList <- countryList()
countryList
```

    ## # A tibble: 192 x 2
    ##    Country             Slug               
    ##    <chr>               <chr>              
    ##  1 Afghanistan         afghanistan        
    ##  2 Albania             albania            
    ##  3 Algeria             algeria            
    ##  4 Andorra             andorra            
    ##  5 Angola              angola             
    ##  6 Antigua and Barbuda antigua-and-barbuda
    ##  7 Argentina           argentina          
    ##  8 Armenia             armenia            
    ##  9 Australia           australia          
    ## 10 Austria             austria            
    ## # … with 182 more rows

``` r
#function to generate data of a particular country

countryData <- function(countrySlug){
  if (countrySlug %in% countryList$Slug){
      url <- paste0("https://api.covid19api.com/total/country/",countrySlug)
      covidData <- GET(url)
      covidDF <- fromJSON(rawToChar(covidData$content))
      dataTibble <- covidDF %>% as_tibble()
  } else {
    message <- paste("ERROR: Argument for country slug is not found.
                     Check the list of countries with its corresponding slug name
                     and use quotation marks.")
    stop(message)
  }
  return(dataTibble)
}

#now we can use the function to generate some data from five sample countries
covidInd <- countryData("indonesia")
covidBang <- countryData("bangladesh")
covidPhil <- countryData("philippines")
covidViet <- countryData("vietnam")
covidThai <- countryData("thailand")
```

# Data Manipulation

``` r
#we can create a function that will manipulate our data to prepare for data summaries and visualization
manipulateData <- function(dataset){
  dataset$Date <- as.Date(dataset$Date)
  dataset <- dataset %>% select(-c(CountryCode, Province, City, CityCode, Lat, Lon)) %>%
                  separate(Date, c("Year", "Month", "Day"), sep="-", convert=T, 
                     remove=F) %>% mutate("NewCases"=diff(c(0, Confirmed)),
                                          "NewDeaths"=diff(c(0, Deaths)))
  dataset$Country <- as.factor(dataset$Country)
  return(dataset)
}

#manipulate each dataset using the function above to prepare for summarization and visualization
covidInd <- manipulateData(covidInd)
covidBang <- manipulateData(covidBang)
covidPhil <- manipulateData(covidPhil)
covidViet <- manipulateData(covidViet)
covidThai <- manipulateData(covidThai)

#histogram
#ggplot(covidPhil, aes(NewDeaths)) + geom_histogram()

#barplot
#dataBarPlot <- dataset %>% filter(Country=="Philippines", Year==2021, Month==9)
#ggplot(dataBarPlot, aes(Day, NewDeaths)) + geom_col()




#dataset <- bind_rows(covidBang, covidInd, covidPhil, covidThai, covidViet)


#datasetPlot <- dataset %>% filter(Country %in% c("Indonesia", "Philippines", "Vietnam"))


#ggplot(dataset, aes(Date,NewDeaths)) + geom_area(aes(fill=Country, alpha=0.5)) + geom_text(aes(label=NewDeaths))


#scatterplot
#dataBarPlot <- dataset %>% filter(Country %in% c("Philippines", "Thailand"), Year==2021, Month==9)
#ggplot(dataBarPlot, aes(Day, NewDeaths)) + geom_jitter(aes(color=Country))

#boxplot
#dataBoxPlot <- dataset %>% filter(Country %in% c("Philippines", "Thailand"), Year==2021, Month==9)

#ggplot(dataBoxPlot, aes(Country %in% c("Philippines", "Thailand"), NewDeaths)) + 
  #geom_boxplot(aes(colour=Country))
```

``` r
#covidInd <- covidInd %>% filter(Year == 2021 & Month == 09)

#ggplot(covidInd, aes(covidInd$Date, covidInd$NewCases)) + geom_col()

#ggplot(covidInd, aes(covidInd$Date, covidInd$NewDeaths)) + geom_col()
```

``` r
#get results of five countries to compare
compareCountries <- function(country1, country2, country3, country4, country5){
  covid <- GET("https://api.covid19api.com/summary")
  covidDF <- fromJSON(rawToChar(covid$content))
  data <- covidDF$Countries %>% as_tibble()
  #checks if first country supplied is in the data, misspelled or lack quotation marks
  if (country1 %in% data$Country){
    output1 <- data %>% filter(data$Country == country1) %>% select(-c(ID,Slug,Premium))
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
  output5 <- data %>% filter(data$Country == country5) %>% select(-c(ID, Slug, Premium))
  }
  else{
    message <- paste("ERROR: Check spelling of fifth country or use quotation marks.")
    stop(message)
  }
  output <- rbind(output1, output2, output3, output4, output5) %>% kable()
  return(output)
}

#check function if it works
compareCountries("Philippines","China", "Mexico", "United States of America", "Australia")
```

| Country                  | CountryCode | NewConfirmed | TotalConfirmed | NewDeaths | TotalDeaths | NewRecovered | TotalRecovered | Date                     |
|:-------------------------|:------------|-------------:|---------------:|----------:|------------:|-------------:|---------------:|:-------------------------|
| Philippines              | PH          |            0 |        2490858 |         0 |       37405 |            0 |              0 | 2021-09-29T00:03:19.855Z |
| China                    | CN          |           35 |         108344 |         0 |        4849 |            0 |              0 | 2021-09-29T00:03:19.855Z |
| Mexico                   | MX          |         3007 |        3635807 |       226 |      275676 |            0 |              0 | 2021-09-29T00:03:19.855Z |
| United States of America | US          |       185088 |       43116442 |      2394 |      690426 |            0 |              0 | 2021-09-29T00:03:19.855Z |
| Australia                | AU          |         1880 |         100911 |        11 |        1256 |            0 |              0 | 2021-09-29T00:03:19.855Z |
