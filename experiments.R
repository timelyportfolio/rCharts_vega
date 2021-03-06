require(ggvis)
#need shiny isolate function for ggvis:::as.vega
require(shiny)

setwd("C:/Users/Kent.TLEAVELL_NT/Dropbox/development/r/rCharts_vega")

g1 <- mtcars %>% ggvis(~mpg, stroke = ~factor(cyl), strokeWidth:=2) %>% group_by(cyl) %>%
  layer_freqpolys(binwidth = 2)

vega_spec <- ggvis:::as.vega(g1)


require(rCharts)
rGG <- rCharts$new()
rGG$setLib(".")
rGG$templates$script = paste0(getwd(),"/chart.html")
rGG$setTemplate(
  afterScript = '
    <script>
    </script>
    '
)

rGG$setTemplate(chartDiv = "
  <div class='container'>
  <!--<input id='slider' type='range' min=1960 max=2010 ng-model='year' width=200>
  <span ng-bind='year'></span>-->
  <input type='range' ng-model='ctrls.mysize' min=1 max=10 />{{ ctrls.mysize }}
  <div id='vis' class='rChart datamaps'></div>  
  </div>
  <script>
  var ctrls = {
    'mysize': 2
  }
  // parse a spec and create a visualization view
  function parse(spec) {
    return vg.parse.spec(spec, function(chart){
      chart({el:'#vis'}).update(); 
    })
  }

  function rChartsCtrl($scope){
    $scope.ctrls = ctrls;
    $scope.$watch('ctrls.mysize', function(linesize){
      opts.spec.marks[0].marks[0].properties.update.strokeWidth = {'value': +linesize}
      parse(opts.spec);
    },true)
  }
  </script>"
)


rGG$set(
  bodyattrs = "ng-app ng-controller='rChartsCtrl'"
)
rGG$set(
  spec = ggvis:::as.vega(g1)
)
#rGG$addAssets(
#  jshead = "http://cdnjs.cloudflare.com/ajax/libs/angular.js/1.2.1/angular.min.js"
#)


rGG
