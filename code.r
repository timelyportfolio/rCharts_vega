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

#########################bar.R########################3
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



###############density.R#######################3
# Basic
vega_spec <- as.vega(
ggvis(faithful, props(x = ~waiting)) + layer_density()
)
vPlot$params$spec <- vega_spec
vPlot

# Smaller bandwidth
vega_spec <- as.vega(
  ggvis(faithful, props(x = ~waiting, fill := "lightblue")) +
  layer_density(adjust = .25)
)
vPlot$params$spec <- vega_spec
vPlot

# Control stroke and fill
vega_spec <- as.vega(
  ggvis(faithful, props(x = ~waiting)) +
  layer_density(props(stroke := "#cc3333", strokeWidth := 3,
                      fill := "#666699", fillOpacity := 0.6))
)
vPlot$params$spec <- vega_spec
vPlot

# With groups
vega_spec <- as.vega(
  ggvis(PlantGrowth, by_group(group),
      props(x = ~weight, stroke = ~group, fill = ~group, fillOpacity := 0.2)) +
  layer_density()
)
vPlot$params$spec <- vega_spec
vPlot

# Various arguments: adjust na.rm, n, area, kernel
mtc <- mtcars
mtc$mpg[5:10] <- NA

vega_spec <- as.vega(
ggvis(mtc, props(x = ~mpg, y = ~mpg)) +
  layer_density(adjust = 0.3, n = 100, area = FALSE, kernel = "rectangular",
                props(stroke := "#cc0000"))
)
vPlot$params$spec <- vega_spec
vPlot



#################guides.R#######################
vega_spec <- as.vega(
  ggvis(mtcars, props(x = ~wt, y = ~mpg, fill = ~cyl)) +
  layer_point()
)
vPlot$params$spec <- vega_spec
vPlot

vega_spec <- as.vega(
  ggvis(mtcars, props(x = ~wt, y = ~mpg, fill = ~cyl)) +
  layer_point() +
  guide_axis("x", title = "Weight")
)
vPlot$params$spec <- vega_spec
vPlot

vega_spec <- as.vega(
  ggvis(mtcars, props(x = ~wt, y = ~mpg, fill = ~cyl)) +
  layer_point() +
  guide_legend(fill = "fill", title = "Cylinders")
)
vPlot$params$spec <- vega_spec
vPlot



###############histogram.R########################
vega_spec <- as.vega(
  ggvis(pipeline(mtcars, transform_bin(binwidth = 1)), props(x = ~wt)) +
  layer(
    props(x = ~xmin__, x2 = ~xmax__, y = ~count__, y2 = 0),
    mark_rect()
  )
)
vPlot$params$spec <- vega_spec
vPlot

# Or using shorthand layer
vega_spec <- as.vega(
  ggvis(mtcars, props(x = ~wt)) + layer_histogram(binwidth = 1)
)
vPlot$params$spec <- vega_spec
vPlot

vega_spec <- as.vega(
  ggvis(mtcars, props(x = ~wt)) + layer_histogram()
)
vPlot$params$spec <- vega_spec
vPlot

# Histogram, filled by cyl
by_cyl <- pipeline(mtcars, by_group(cyl))
vega_spec <- as.vega(
  ggvis(by_cyl, props(x = ~wt, fill = ~factor(cyl))) +
  layer_histogram(binwidth = 1)
)
vPlot$params$spec <- vega_spec
vPlot

vega_spec <- as.vega(
  ggvis(by_cyl, props(x = ~wt, stroke = ~factor(cyl))) +
  layer_freqpoly(binwidth = 1)
)
vPlot$params$spec <- vega_spec
vPlot


# Bigger dataset
data(diamonds, package = "ggplot2")
vega_spec <- as.vega(
  ggvis(diamonds, props(x = ~table)) +
  layer_histogram()
)
vPlot$params$spec <- vega_spec
vPlot


# Stacked histogram
vega_spec <- as.vega(
  ggvis(diamonds, by_group(cut), props(x = ~table, fill = ~cut),
      transform_bin(binwidth = 1)) +
  layer(
    props(x = ~xmin__, x2 = ~xmax__, y = ~count__, fillOpacity := 0.6),
    layer(
      transform_stack(),
      mark_rect(props(y = ~ymax__, y2 = ~ymin__))
    )
  )
)
vPlot$params$spec <- vega_spec
vPlot

# Histogram of dates
set.seed(2934)
dat <- data.frame(times = as.POSIXct("2013-07-01", tz = "GMT") + rnorm(200) * 60 * 60 * 24 * 7)
vega_spec <- as.vega(
  ggvis(dat, props(x = ~times)) + layer_histogram()
)
vPlot$params$spec <- vega_spec
vPlot



################hover.R###########################
# Scatter plot with hovering
vega_spec <- as.vega(
  ggvis(mtcars, props(x = ~wt, y = ~mpg, size.hover := 200)) +
  layer_point()
)
vPlot$params$spec <- vega_spec
vPlot

# Larger point and outline when hovering
vega_spec <- as.vega(
  ggvis(mtcars,
      props(x = ~wt, y = ~mpg, size.hover := 200,
            stroke := NA, stroke.hover := "red", strokeWidth := 3)) +
  layer_point()
)
vPlot$params$spec <- vega_spec
vPlot

# Line changes color and points change size when hovered over, with 250 ms
# transition time
vega_spec <- as.vega(
  ggvis(pressure, props(x = ~temperature, y = ~pressure)) +
  mark_path(props(stroke.hover := "red", strokeWidth.hover := 4, strokeWidth := 2)) +
  layer_point(props(size := 50, size.hover := 200)) +
  opts(hover_duration = 250)
)
vPlot$params$spec <- vega_spec
vPlot

# Hover with transform_smooth
vega_spec <- as.vega(
  ggvis(mtcars, props(x = ~wt, y = ~mpg)) +
  layer_point() +
  layer_smooth(props(fill.hover := "red"))
)
vPlot$params$spec <- vega_spec
vPlot

# Opacity with transform_density
vega_spec <- as.vega(
  ggvis(PlantGrowth, by_group(group),
      props(x = ~weight, stroke = ~group, fill = ~group, fillOpacity := 0.2, fillOpacity.hover := .5)) +
  layer_density()
)
vPlot$params$spec <- vega_spec
vPlot
