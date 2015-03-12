queue()
    .defer(d3.xhr, activity_report)
    .defer(d3.xhr, pollution_report)
    .await(ready);

function ready(error, activity, pollution) {
  
  activity_data = JSON.parse(activity.response)
  d3.selectAll('.activity .value')
    .text(activity_data.properties.total_features)
    
    
  pollution_data = JSON.parse(pollution.response)
  d3.selectAll('.pollution .value')
    .text(pollution_data.properties.total_features)
    
  total_reports = activity_data.properties.total_features + pollution_data.properties.total_features
    d3.selectAll('.total')
     .text(total_reports)
     
     
   pollution_data_percentage = Math.round((pollution_data.properties.total_features/total_reports)*100);
   console.log(pollution_data_percentage)
    d3.selectAll('.pollution .gauge .bar')
      .style('width', pollution_data_percentage + "%")

  activity_data_percentage = Math.round((activity_data.properties.total_features/total_reports)*100);
  console.log(activity_data_percentage)
   d3.selectAll('.activity .gauge .bar')
     .style('width', activity_data_percentage + "%")
  
  
  
  console.log('All data ready!', activity, pollution)
}


  // var application_data, activity_count = 0, total_reports = 0;
  // 
  // var sum_reports = function (this_count) {
  //   total_reports = (total_reports + this_count)
  //   
  //   d3.selectAll('.total')
  //    .text(total_reports)
  // 
  //   console.log("Total: " + total_reports)
  // }
  // 
  // d3.xhr(activity_report, function(error, pjson) {
  //   // ?
  // }).on('load', function (d) {
  // 
  //   var this_data = JSON.parse(d.response)
  //   var this_count = this_data.count
  // 
  //   // Display the data
  //   d3.selectAll('.activity .value')
  //     .text(this_count)
  //     
  //   sum_reports(this_count)
  // });
  // 
  // d3.xhr(pollution_report, function(error, pjson) {
  //   // ?
  // }).on('load', function (d) {
  // 
  //   var this_data = JSON.parse(d.response)
  //   var this_count = this_data.count
  // 
  //   // Display the data
  //   d3.selectAll('.pollution .value')
  //     .text(this_count)
  // 
  //     sum_reports(this_count)
  //     
  //   d3.selectAll('.pollution .gauge.bar').attr('width', this_count)
  //   
  // });
  // 
  // d3.select('body').on('load', function (d) {
  //   console.log('Application loaded. Total reports > ' + total_reports)
  // });
