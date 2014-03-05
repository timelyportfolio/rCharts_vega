#explore d3 candlesticks with vega through ggvis and rCharts

#do the ggvis part
#do load_all instead of require
#so we have access to the internal functions of ggvis
setwd("C:/Users/Kent.TLEAVELL_NT/Dropbox/development/r/ggvis")
require(devtools)
load_all()
#need shiny isolate function for as.vega
require(shiny)

setwd("C:/Users/Kent.TLEAVELL_NT/Dropbox/development/r/rCharts_vega")
#just get some data to plot
require(quantmod);require(xts)
price <- getSymbols('SPY',from="2013-12-31",auto.assign=F)

price.df <- na.omit(data.frame(
  index(price), #as.numeric(index(price)),
  price,
  ifelse(price[,4]>lag.xts(price,1)[,4],"yes","no"),
  ifelse(price[,4]>price[,1],1,0)
))
colnames(price.df) <- c(
  "date","open","high","low","close","volume","adjclose","color","opacity"
)

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

vega_spec <- as.vega(
  ggvis(price.df, 
    props(
      y = ~close, x = ~date, fill = ~color, fillOpacity = ~opacity, stroke = ~color
    )
  ) +
    mark_rect(props(y2 = ~open, width := 3)) +
    mark_rect(props(y =~ high, y2 = ~low, width := 0.5, fillOpacity := 1)) +
    dscale("fill", "ordinal", range = c("red","green"), domain=c("no","yes")) +
    dscale("stroke", "ordinal", range = c("red","green"), domain=c("no","yes")) +
    dscale("x", "datetime", nice = "week")
)
vPlot$params$spec = vega_spec

sink("candlestick.html")
cat(gsub(
  x = vPlot$render(cdn=F),
  pattern = "C:\\\\Users\\\\Kent.TLEAVELL_NT\\\\Dropbox\\\\development\\\\r\\\\rCharts_vega/",
  replacement = ""
))
sink()
