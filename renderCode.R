#run code in the console to knit github_document

rmarkdown::render("index.Rmd",output_format='github_document',
                  output_options=list(html_preview=FALSE, keep_html=FALSE))


#site
# https://jerryendrina.github.io/Covid-19-API-Vignette/