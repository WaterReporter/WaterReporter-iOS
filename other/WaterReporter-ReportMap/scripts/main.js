"use strict";

(function () {


  var map = {
    class: 'site-map',
    mapbox_id: '',

  }



   L.mapbox.accessToken = 'pk.eyJ1IjoiZGV2ZWxvcGVkc2ltcGxlIiwiYSI6IkFWaGZPVUEifQ.JuZ21Q5vqECOkOwdCgIl6g';
    
      var geojson = [
        {
          "type": "Feature",
          "geometry": {
            "type": "LineString",
            "coordinates": [
              [-77.03238901390978,38.913188059745586],
              [-122.414, 37.776]
            ]
          },
          "properties": {
            "stroke": "#fc4353",
            "stroke-width": 5
          }
        }
      ];

      var map = L.mapbox.map(map.class, map.mapbox_id).setView([37.8, -96], 4);

      L.geoJson(geojson, { style: L.mapbox.simplestyle.style }).addTo(map);

})();