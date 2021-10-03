03 October, 2021

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
#function that generates a vector of countries and their corresponding Slug name whose data are update daily.

countryList <- function(){
  covid <- GET("https://api.covid19api.com/countries")
  covidDF <- fromJSON(rawToChar(covid$content))
  countryList <- covidDF %>% as_tibble()
  return(countryList)
}

countryList <- countryList()
head(countryList)
```

    ## # A tibble: 6 x 3
    ##   Country                  Slug                     ISO2 
    ##   <chr>                    <chr>                    <chr>
    ## 1 Poland                   poland                   PL   
    ## 2 Comoros                  comoros                  KM   
    ## 3 Djibouti                 djibouti                 DJ   
    ## 4 Turks and Caicos Islands turks-and-caicos-islands TC   
    ## 5 Bulgaria                 bulgaria                 BG   
    ## 6 Honduras                 honduras                 HN

``` r
#a function to determine the slug name of a country

countrySlugAbbrev <- function(inputCountry){
  if (inputCountry %in% countryList$Country){
      covidData <- GET("https://api.covid19api.com/countries")
      covidDF <- fromJSON(rawToChar(covidData$content))
      dataTibble <- covidDF %>% filter(Country == inputCountry ) %>% as_tibble()
  } else {
    message <- paste("ERROR: Argument for country cannot be found, check spelling.
                     Lastly, use quotation marks in your arguments.")
    stop(message)
  }
  return(dataTibble)
}
  
countrySlugAbbrev("United States of America")
```

    ## # A tibble: 1 x 3
    ##   Country                  Slug          ISO2 
    ##   <chr>                    <chr>         <chr>
    ## 1 United States of America united-states US

``` r
#function to determine the date of the first confirmed covid case of a country
firstCase <- function(countrySlug){
  if (countrySlug %in% countryList$Slug){
      url <- paste0("https://api.covid19api.com/dayone/country/",countrySlug,"/status/confirmed")
      covidData <- GET(url)
      covidDF <- fromJSON(rawToChar(covidData$content))
      dataTibble <- covidDF %>% select(Country, Cases, Status, Date) %>% as_tibble()
  } else {
    message <- paste("ERROR: Argument for country nslug cannot be found, check spelling.
                     Lastly, use quotation marks in your arguments.")
    stop(message)
  }
  return(dataTibble[1,])
}

firstCase("philippines")
```

    ## # A tibble: 1 x 4
    ##   Country     Cases Status    Date                
    ##   <chr>       <int> <chr>     <chr>               
    ## 1 Philippines     1 confirmed 2020-01-30T00:00:00Z

``` r
#confirmed cumulative cases of a country in a specific range of time
#specific country and specific time, start and end date must be in the format yyyy-mm-dd

casesCountryTime <- function(countrySlug, startDate, endDate){
  if (countrySlug %in% countryList$Slug){
      url <- paste0("https://api.covid19api.com/total/country/",countrySlug,
                    "/status/confirmed?from=",startDate,"T00:00:00Z&to=",endDate,"T00:00:00Z")
      covidData <- GET(url)
      covidDF <- fromJSON(rawToChar(covidData$content))
      dataTibble <- covidDF %>% select(Country, Cases, Status, Date) %>% as_tibble()
  } else {
    message <- paste("ERROR: Argument for country slug may not be found, check the list of 
                      countries with its corresponding slug name. Start and end dates are might
                      have formatted incorrectly. Lastly, use quotation marks in your arguments.")
    stop(message)
  }
  return(dataTibble)
}

philSept <- casesCountryTime("philippines","2021-09-01", "2021-09-30")
head(philSept)
```

    ## # A tibble: 6 x 4
    ##   Country       Cases Status    Date                
    ##   <chr>         <int> <chr>     <chr>               
    ## 1 Philippines 2003955 confirmed 2021-09-01T00:00:00Z
    ## 2 Philippines 2020484 confirmed 2021-09-02T00:00:00Z
    ## 3 Philippines 2040568 confirmed 2021-09-03T00:00:00Z
    ## 4 Philippines 2061084 confirmed 2021-09-04T00:00:00Z
    ## 5 Philippines 2080984 confirmed 2021-09-05T00:00:00Z
    ## 6 Philippines 2103331 confirmed 2021-09-06T00:00:00Z

``` r
#function to get data of a country's cumulative cases of the following: Confirmed, Deaths, Recovered and Active.

variableCountryTime <- function(countrySlug, startDate, endDate, type){
  if (countrySlug %in% countryList$Slug){
      url <- paste0("https://api.covid19api.com/country/",countrySlug,
                    "?from=",startDate,"T00:00:00Z&to=",endDate,"T00:00:00Z")
      covidData <- GET(url)
      covidDF <- fromJSON(rawToChar(covidData$content))
      dataTibble <- covidDF %>% select(Country, type, Date) %>% as_tibble()
  } else {
    message <- paste("ERROR: Argument for country slug may not be found, check the list of 
                      countries with its corresponding slug name. Start and end dates 
                      are might have formatted incorrectly. Lastly, use quotation marks in your arguments.")
    stop(message)
  }
  return(dataTibble)
}

philSept <- variableCountryTime("philippines","2021-09-26", "2021-10-02", "Deaths")
philSept
```

    ## # A tibble: 7 x 3
    ##   Country     Deaths Date                
    ##   <chr>        <int> <chr>               
    ## 1 Philippines  37405 2021-09-26T00:00:00Z
    ## 2 Philippines  37405 2021-09-27T00:00:00Z
    ## 3 Philippines  37596 2021-09-28T00:00:00Z
    ## 4 Philippines  38164 2021-09-29T00:00:00Z
    ## 5 Philippines  38294 2021-09-30T00:00:00Z
    ## 6 Philippines  38493 2021-10-01T00:00:00Z
    ## 7 Philippines  38656 2021-10-02T00:00:00Z

``` r
#get latest results of five countries to compare
compareCountries <- function(country1, country2, country3, country4, country5){
  covid <- GET("https://api.covid19api.com/summary")
  covidDF <- fromJSON(rawToChar(covid$content))
  data <- covidDF$Countries %>% as_tibble()
  countries <- c(country1, country2, country3, country4, country5)
  finalData <- data.frame(matrix(ncol=6,nrow=0))
  names(finalData) <- c("Country","NewConfirmed","TotalConfirmed","NewDeaths","TotalDeaths","Date")
  for (country in countries){
    if (country %in% data$Country){
      finalData[nrow(finalData)+1, ] <- data %>% filter(data$Country == country) %>% 
        select(c(Country,NewConfirmed,TotalConfirmed,NewDeaths,TotalDeaths,Date))
    }
    else{
      message <- paste("ERROR: Check spelling of first country or use quotation marks.")
      stop(message)
    }
  }
  return(finalData %>% as_tibble())
}  
  
compareCountries("Philippines","China", "Mexico", "United States of America", "Canada")
```

    ## # A tibble: 5 x 6
    ##   Country                  NewConfirmed TotalConfirmed NewDeaths TotalDeaths Date                    
    ##   <chr>                           <int>          <int>     <int>       <int> <chr>                   
    ## 1 Philippines                         0        2580173         0       38656 2021-10-03T11:34:47.708Z
    ## 2 China                              33         108528         0        4849 2021-10-03T11:34:47.708Z
    ## 3 Mexico                           7369        3678980       614      278592 2021-10-03T11:34:47.708Z
    ## 4 United States of America        39206       43657833       647      700932 2021-10-03T11:34:47.708Z
    ## 5 Canada                           1728        1339341        22       25264 2021-10-03T11:34:47.708Z

``` r
#function to generate all data (daily new cases, deaths, active and recoveries) of a particular country since the start of the pandemic

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
covidUS <- countryData("united-states")
tail(covidUS)
```

    ## # A tibble: 6 x 12
    ##   Country        CountryCode Province City  CityCode Lat   Lon   Confirmed Deaths Recovered  Active Date       
    ##   <chr>          <chr>       <chr>    <chr> <chr>    <chr> <chr>     <int>  <int>     <int>   <int> <chr>      
    ## 1 United States… ""          ""       ""    ""       0     0      43116877 690435         0  4.24e7 2021-09-27…
    ## 2 United States… ""          ""       ""    ""       0     0      43226482 692592         0  4.25e7 2021-09-28…
    ## 3 United States… ""          ""       ""    ""       0     0      43349749 695123         0  4.27e7 2021-09-29…
    ## 4 United States… ""          ""       ""    ""       0     0      43460343 697851         0  4.28e7 2021-09-30…
    ## 5 United States… ""          ""       ""    ""       0     0      43618627 700285         0  4.29e7 2021-10-01…
    ## 6 United States… ""          ""       ""    ""       0     0      43657833 700932         0  4.30e7 2021-10-02…
