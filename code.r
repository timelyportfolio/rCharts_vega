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

vPlot <- rCharts$new()
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