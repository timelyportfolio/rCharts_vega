require(ggvis)
require(dplyr)
require(shiny) #need shiny isolate function for as.vega

#build a rCharts wrapper
require(rCharts)
options( viewer=NULL )

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

# with examples from help/library/ggvis/doc/cookbook.html
# Scatterplots

vPlot$params$spec <- mtcars %>% ggvis(~wt, ~mpg) %>% layer_points() %>%
  ggvis:::as.vega()
vPlot

vPlot$params$spec <- mtcars %>% 
  ggvis(~wt, ~mpg) %>% 
  layer_points(size := 25, shape := "diamond", stroke := "red", fill := NA) %>%
  ggvis:::as.vega()
vPlot


vPlot$params$spec <- mtcars %>% 
  ggvis(~wt, ~mpg) %>%
  layer_points() %>%
  layer_smooths() %>%
  ggvis:::as.vega()
vPlot

vPlot$params$spec <- mtcars %>% 
  ggvis(~wt, ~mpg) %>%
  layer_points() %>%
  layer_model_predictions(model = "lm", se = TRUE) %>%
  ggvis:::as.vega()
vPlot

vPlot$params$spec <- mtcars %>% 
  ggvis(~wt, ~mpg) %>% 
  layer_points(fill = ~factor(cyl)) %>%
  ggvis:::as.vega()
vPlot

#does not work
vPlot$params$spec <- mtcars %>% 
  ggvis(~wt, ~mpg, fill = ~factor(cyl)) %>% 
  layer_points() %>% 
  group_by(cyl) %>% 
  layer_model_predictions(model = "lm") %>%
  ggvis:::as.vega()
vPlot




# Bar Graphs

vPlot$params$spec <- pressure %>% 
  ggvis(~temperature, ~pressure) %>%
  layer_bars() %>%
  ggvis:::as.vega()
vPlot

vPlot$params$spec <- pressure %>% 
  ggvis(~temperature, ~pressure) %>%
  layer_bars(width = 10) %>%
  ggvis:::as.vega()
vPlot


pressure2 <- pressure %>% mutate(temperature = factor(temperature))
vPlot$params$spec <- pressure2 %>% ggvis(~temperature, ~pressure) %>%
  layer_bars() %>%
  ggvis:::as.vega()
vPlot

vPlot$params$spec <- pressure %>% ggvis(~temperature, ~pressure) %>%
  layer_bars() %>%
  ggvis:::as.vega()
vPlot


# Line Graphs

vPlot$params$spec <- pressure %>% ggvis(~temperature, ~pressure) %>% layer_lines() %>%
  ggvis:::as.vega()
vPlot

vPlot$params$spec <- pressure %>% ggvis(~temperature, ~pressure) %>%
  layer_points() %>% 
  layer_lines() %>%
  ggvis:::as.vega()
vPlot


# Histograms

vPlot$params$spec <- faithful %>% ggvis(~eruptions) %>% layer_histograms() %>%
  ggvis:::as.vega()
vPlot

vPlot$params$spec <- faithful %>% ggvis(~eruptions, fill := "#fff8dc") %>%
  layer_histograms(binwidth = 0.25) %>%
  add_axis("x", title = "eruptions") %>%
  add_axis("y", title = "count") %>%
  ggvis:::as.vega()
vPlot