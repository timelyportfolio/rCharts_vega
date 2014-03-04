#do the ggvis part
#do load_all instead of require
#so we have access to the internal functions of ggvis
setwd("C:/Users/Kent.TLEAVELL_NT/Dropbox/development/r/ggvis")
require(devtools)
load_all()
#need shiny isolate function for as.vega
require(shiny)

setwd("C:/Users/Kent.TLEAVELL_NT/Dropbox/development/r/rCharts_vega")


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

g1 <- ggvis(
  mtcars,
  props(
    x = ~mpg,
    stroke = ~cyl,
    strokeWidth := 4
  ),
  by_group(cyl),
  layer_freqpoly(binwidth = 2)
)

vega_spec <- as.vega(g1)

vPlot$set(
  spec = vega_spec
)
vPlot


# Bar graph with continuous x, and bars 15 pixels wide
vega_spec <- as.vega(
  ggvis(pressure, props(x = ~temperature, y = ~pressure)) +
    mark_rect(props(y2 = 0, width := 15))
)
vPlot$params$spec = vega_spec
vPlot

# Bar graph with continuous x, and bars occupying full width
vega_spec <- as.vega(
  ggvis(pressure, props(x = ~temperature + 10, x2 = ~temperature - 10,
                      y = ~pressure, y2 = 0)) +
  mark_rect()
)
vPlot$params$spec = vega_spec
vPlot


# Bar graph with categorical x
vega_spec <- as.vega(
  ggvis(pressure, props(x = ~temperature, y = ~pressure)) +
  dscale("x", "nominal", padding = 0, points = FALSE) +
  mark_rect(props(y2 = 0, width = band()))
)
vPlot$params$spec = vega_spec
vPlot

# Hair and eye color data
library(plyr)
hec <- as.data.frame(HairEyeColor)
hec <- ddply(hec, c("Hair", "Eye"), summarise, Freq = sum(Freq))

# Without stacking - bars overlap
vega_spec <- as.vega(
ggvis(hec, props(x = ~Hair, y = ~Freq, fill = ~Eye, fillOpacity := 0.5)) +
  dscale("x", "nominal", range = "width", padding = 0, points = FALSE) +
  mark_rect(props(y2 = 0, width = band()))
)
vPlot$params$spec <- vega_spec
vPlot

# With stacking
vega_spec <- as.vega(
ggvis(hec, transform_stack(),
      props(x = ~Hair, y = ~Freq, fill = ~Eye, fillOpacity := 0.5)) +
  dscale("x", "nominal", range = "width", padding = 0, points = FALSE) +
  mark_rect(props(y = ~ymin__, y2 = ~ymax__, width = band()))
)
vPlot$params$spec <- vega_spec
vPlot

# Stacking in x direction instead of default y
vega_spec <- as.vega(
ggvis(hec, transform_stack(direction = "x"),
      props(x = ~Freq, y = ~Hair, fill = ~Eye, fillOpacity := 0.5)) +
  dscale("y", "nominal", range = "height", padding = 0, points = FALSE) +
  mark_rect(props(x = ~xmin__, x2 = ~xmax__, height = band()))
)
vPlot$params$spec <- vega_spec
vPlot