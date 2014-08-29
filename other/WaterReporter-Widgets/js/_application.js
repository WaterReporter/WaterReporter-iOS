var dataset = [],
    counts = [];

var select_all_layer_counts = function() {
  
  var layer_counter = 1
  
  for (layer in layers) {
    d3.xhr(layers[layer], function(error, pjson) {
      var this_data = JSON.parse(pjson.response)
      return_data(this_data)
    });
  }
  
  return_data(dataset);
}

var return_data = function (these_data) {  
  
  d3.select('body')
    .append('p')
    .text(these_data.count)
    
}

var results = select_all_layer_counts()

