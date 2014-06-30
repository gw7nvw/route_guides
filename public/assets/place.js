
function place_init() {
OpenLayers.Control.Click = OpenLayers.Class(OpenLayers.Control, {                
     defaultHandlerOptions: {
         'single': true,
         'double': true,
         'pixelTolerance': 0,
         'stopSingle': false,
         'stopDouble': false
     },

    initialize: function(options) {
       this.handlerOptions = OpenLayers.Util.extend(
           {}, this.defaultHandlerOptions
       );
       OpenLayers.Control.prototype.initialize.apply(
           this, arguments
       ); 
       this.handler = new OpenLayers.Handler.Click(
           this, {
               'click': this.trigger
           }, this.handlerOptions
       );
    }, 

    trigger: function(e) {
        var lonlat = map_map.getLonLatFromPixel(e.xy);

    /*convert to map projection */

    var dstProj =  map_map.displayProjection;
    var mapProj =  map_map.projection;
    var thisPoint = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat).transform(mapProj,dstProj);

    document.placeform.place_x.value=thisPoint.x;
    document.placeform.place_y.value=thisPoint.y;
    document.placeform.place_projn.value=dstProj;

    /* convert to WGS84 and writ to location */
    var dstProj =  new OpenLayers.Projection("EPSG:4326");
    var thisPoint = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat).transform(mapProj,dstProj);
  
    document.placeform.place_location.value=thisPoint.x+" "+thisPoint.y;

    /* move the star */
    vectorLayer.destroyFeatures();

    var point = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat);
    var pointFeature = new OpenLayers.Feature.Vector(point,null,style_blue);
    vectorLayer.addFeatures(pointFeature);

    }

});


Proj4js.defs["EPSG:2193"] = "+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
Proj4js.defs["EPSG:900913"] = "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs";

if (typeof(map_map)=='undefined') init();

   style_blue = OpenLayers.Util.extend({}, layer_style);
   style_blue.strokeColor = "blue";
   style_blue.fillColor = "blue";
   style_blue.graphicName = "star";
   style_blue.pointRadius = 10;
   style_blue.strokeWidth = 3;
   style_blue.rotation = 45;
   style_blue.strokeLinecap = "butt";


vectorLayer = new OpenLayers.Layer.Vector("Current feature", {
                style: layer_style,
                renderers: renderer
            });
 /* get location from form */
 var x = document.placeform.place_x.value;
 var y = document.placeform.place_y.value;
 var proj = document.placeform.place_projn.value;

/*convert to map projectiob */
var srcProj =  new OpenLayers.Projection("EPSG:2193");
var mapProj =  new OpenLayers.Projection("EPSG:900913");
var thisPoint = new OpenLayers.Geometry.Point(x, y).transform(srcProj, mapProj);

/*add to map */
          var point = new OpenLayers.Geometry.Point(thisPoint.x,thisPoint.y)
            var pointFeature = new OpenLayers.Feature.Vector(point,null,style_blue);
            vectorLayer.addFeatures(pointFeature);
            map_map.addLayer(vectorLayer);
/* turn on click to get coords */
    click.activate();
}



