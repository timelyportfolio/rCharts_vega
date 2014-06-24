---
title: rCharts Peeks Under the Hood of ggvis
subtitle: Get a Better Understanding of ggvis + vega
framework: bootstrap
mode     : selfcontained # {standalone, draft}
highlighter: prettify
hitheme: twitter-bootstrap
assets:
  css:
    - http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css
    - http://fonts.googleapis.com/css?family=Roboto:300,400
    - http://fonts.googleapis.com/css?family=Oxygen:300

---    

<style>
body{
  font-family: 'Oxygen', sans-serif;
  font-size: 16px;
  line-height: 24px;
}

h1,h2,h3,h4 {
font-family: 'Raleway', sans-serif;
}

.container { width: 1000px; }

h3 {
background-color: #D4DAEC;
  text-indent: 100px; 
}

h4 {
text-indent: 100px;
}
</style>



<div class="page-header">
  <h1>{{ page.title }}</h1>
  <h3>{{ page.subtitle }}</h3>
</div>

I have enjoyed watching the development of [`ggvis`](http://github.com/rstudio/ggvis).  A while back I wanted to understand the inner workings of `ggvis`, so I hacked together a combination of [Vega Live Editor](http://trifacta.github.io/vega/editor/), [`rCharts`](http://rcharts.io), and [Ramnath Vaidyanathan's Live `rCharts` editor](http://ramnathv.github.io/posts/making-rcharts-live-app/index.html) to play with the underlying `ggvis` spec.  Now that `ggvis` has reached a level of maturity for it to [reach CRAN](http://blog.rstudio.org/2014/06/23/introducing-ggvis/), I thought it might be helpful to share the interactive playground using Scatterplot Example 3 from the [`ggvis` cookbook](http://ggvis.rstudio.com/cookbook.html).

You can run all of the examples in the playground from the [`ggvis` cookbook](http://ggvis.rstudio.com/cookbook.html) with this [code.R](https://github.com/timelyportfolio/rCharts_vega/blob/gh-pages/code.r).

---
<div class="col-md-12">
  <iframe src = "vega_example.html" width = 100% height = 800px></iframe>
<div>

---
### Load All of Our Packages


```r
require(ggvis)
require(dplyr)
require(shiny) #need shiny isolate function for as.vega

#build a rCharts wrapper
require(rCharts)
options( viewer=NULL )
```

---
### Build an rCharts Wrapper

```r
rCharts_vega <- setRefClass(
  "rCharts_vega",
  contains = "rCharts",
  methods = list(
    initialize = function(){
      callSuper(); 
    },
    getPayload = function(chartId){
      list(
        chartParams = RJSONIO::toJSON(params),
        chartId = chartId,
        lib = basename(lib), 
        liburl = LIB$url
      )
    })
)

vPlot <- rCharts_vega$new()
vPlot$setLib( "." )
vPlot$templates$script = "./chart_vega.html"
vPlot$set(
  bodyattrs = "ng-app='myApp' ng-controller='MainCtrl'"
)
vPlot$setTemplate(
  chartDiv = "<div></div>"
)
vPlot$setTemplate(
  afterScript = "
  <script>
  </script>     
  "
)
```

---
### Scatterplots Example 3


```r
# with examples from help/library/ggvis/doc/cookbook.html

vPlot$params$spec <- mtcars %>% 
  ggvis(~wt, ~mpg) %>%
  layer_points() %>%
  layer_smooths() %>%
  ggvis:::as.vega()
vPlot
```




