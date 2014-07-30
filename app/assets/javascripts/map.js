var map_map;
var vectorLayer;
var places_layer;
var routes_layer;
var renderer;

var layer_style;
var pt_styleMap;
var rt_styleMap;
var style_pt_default;
var style_rt_default;
var star_purple;
var star_red;
var star_green;
var star_blue;
var line_red;

var select;
var click_to_select_all;
var click_to_copy_start_point;
var click_to_copy_report_link;
var click_to_copy_end_point;
var click_to_create;
var link_item_type="test";
var draw;

var statusMessage = 0;
var autoPlacesOff = false;
var placesStale=false;
var routesStale=false;
var tripsStale=false;

var itemToCut;
var positionToPaste;

function init(){
  if(typeof(map_map)=='undefined') {

    /* explicityly define the projections we will use */
    Proj4js.defs["EPSG:2193"] = "+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
    Proj4js.defs["EPSG:900913"] = "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs";
    Proj4js.defs["EPSG:27200"] = "+proj=nzmg +lat_0=-41 +lon_0=173 +x_0=2510000 +y_0=6023150 +ellps=intl +datum=nzgd49 +units=m +no_defs";

    /* define our point styles */
    create_styles();

    map_map = new OpenLayers.Map( 'map_map', {
            displayProjection: new OpenLayers.Projection("EPSG:2193"),
            projection: new OpenLayers.Projection("EPSG:900913"),
            numZoomLevels: null, minZoomLevel: 6, maxZoomLevel: 14 
    } );



    renderer = OpenLayers.Util.getParameters(window.location.href).renderer;
    renderer = (renderer) ? [renderer] : OpenLayers.Layer.Vector.prototype.renderers;

    layer_style = OpenLayers.Util.extend({}, OpenLayers.Feature.Vector.style['default']);
    layer_style.fillOpacity = 0.2;
    layer_style.graphicOpacity = 1;

    var extent = new OpenLayers.Bounds(18842642.180088, -5791195.9326324, 19729515.150218,  -4476561.4562925);
    var basemap_layer = new OpenLayers.Layer.WMTS({
        name: "nztopomaps.com",
        url: "http://routeguides.co.nz/mapcache/wmts/",
        layer: 'test',
        matrixSet: 'g',
        format: 'image/png',
        style: 'default',
        gutter:0,buffer:0,isBaseLayer:true,transitionEffect:'resize',
        resolutions:[2445.98490512564012533403,1222.99245256282006266702,611.49622628141003133351,305.74811314070478829308,152.87405657035250783338,76.43702828517623970583,38.21851414258812695834,19.10925707129405992646,9.55462853564703173959],
        zoomOffset:6,
        units:"m",
        maxExtent: new OpenLayers.Bounds(-20037508.342789,-20037508.342789,20037508.342789,20037508.342789),
        projection: new OpenLayers.Projection("EPSG:900913".toUpperCase()),
        sphericalMercator: true
      }
    );

    places_layer_add();
    routes_layer_add();

    map_map.addLayer(basemap_layer);
    map_map.addLayer(places_layer);
    map_map.addLayer(routes_layer);

    map_map.zoomToExtent(extent); 
    map_map.addControl(new OpenLayers.Control.LayerSwitcher());
    map_map.addControl(new OpenLayers.Control.MousePosition());
    
    // Create a select feature control and add it to the map.
    select = new OpenLayers.Control.SelectFeature([places_layer, routes_layer], {hover: true});
    map_map.addControl(select);
    select.activate();

    //callback for moveend event 
    map_map.events.register("zoomend", map_map, function() {
       var x = map_map.getZoom();
        
        if( x > 9) {
            map_map.zoomTo(9);
        }
        if( x < 0) {
            map_map.zoomTo(0);
        }
        // hide places above 7 zoom (too much data).  Turn back on if we drop below 
        if( x < 2) {
            places_layer.setVisibility(false);
            autoPlacesOff=true;
       } else {
            if (autoPlacesOff==true) {
                places_layer.setVisibility(true);
            }
       }
    });

    vectorLayer = new OpenLayers.Layer.Vector("Current feature", {
                style: layer_style,
                renderers: renderer,
                projection: new OpenLayers.Projection("EPSG:900913".toUpperCase())
            });
    map_map.addLayer(vectorLayer);

   /* arrange layer order */
//   map_map.setLayerIndex(basemap_layer,100);
 //  map_map.setLayerIndex(places_layer,200);
  // map_map.setLayerIndex(routes_layer,300);
   //map_map.setLayerIndex(vector_layer,400);
//
   //map_map.redraw();

    /* create click controllers*/
    add_click_to_select_all_controller();
    click_to_select_all = new OpenLayers.Control.Click();
    map_map.addControl(click_to_select_all);

    add_click_to_copy_report_link();
    click_to_copy_report_link = new OpenLayers.Control.Click();
    map_map.addControl(click_to_copy_report_link);

    add_click_to_copy_start_point();
    click_to_copy_start_point = new OpenLayers.Control.Click();
    map_map.addControl(click_to_copy_start_point);

    add_click_to_copy_end_point();
    click_to_copy_end_point = new OpenLayers.Control.Click();
    map_map.addControl(click_to_copy_end_point);

    add_click_to_create_controller();
    click_to_create = new OpenLayers.Control.Click();
    map_map.addControl(click_to_create);

    add_draw_controller();

    /* by default, activate only xclick_to_select */
    click_to_select_all.activate();

    // hide places below 2 zoom (too much data).  Turn back on if we drop beloiw 
    if( map_map.getZoom() < 2) {
        places_layer.setVisibility(false);
        autoPlacesOff=true;
   } else {
        if (autoPlacesOff==true) {
            places_layer.setVisibility(true);
        }
   }

  }
}

function places_layer_add() {
    places_layer = new OpenLayers.Layer.Vector("Places", {
                    strategies: [new OpenLayers.Strategy.BBOX()],
                    protocol: new OpenLayers.Protocol.WFS({
                        url:  "http://routeguides.co.nz/cgi-bin/mapserv?map=/ms4w/apps/matts_app/htdocs/places.map",
                        featureType: "places",
                        extractAttributes: true
                    }),
                    styleMap: pt_styleMap
                });



   /* copy selected feature to div */
    places_layer.events.on({
        'featureselected': function(feature) {
	     var f = places_layer.selectedFeatures.pop();
             document.selectform.select.value = f.attributes.id;
             document.selectform.selectname.value = f.attributes.name;
             document.selectform.selectx.value = f.geometry.x;
             document.selectform.selecty.value = f.geometry.y;
             document.selectform.selecttype.value = "/places/";

           },
           'featureunselected': function(feature) {
             document.selectform.select.value = "";
             document.selectform.selectname.value = "";
             document.selectform.selectx.value = "";
             document.selectform.selecty.value = "";
             document.selectform.selecttype.value = "";

           }
    });
}

function routes_layer_add() {

    routes_layer = new OpenLayers.Layer.Vector("routes", {
                    strategies: [new OpenLayers.Strategy.BBOX()],
                    protocol: new OpenLayers.Protocol.WFS({
                        url:  "http://routeguides.co.nz/cgi-bin/mapserv?map=/ms4w/apps/matts_app/htdocs/routes.map",
                        featureType: "routes",
                        extractAttributes: true
                    }),
                    styleMap: rt_styleMap
                });

            
   /* copy selected feature to div */
    routes_layer.events.on({
        'featureselected': function(feature) {
             var f = routes_layer.selectedFeatures.pop();
             document.selectform.select.value = f.attributes.id;
             document.selectform.selectname.value = f.attributes.name;
             document.selectform.selectx.value = f.geometry.x;
             document.selectform.selecty.value = f.geometry.y;
             document.selectform.selecttype.value = "/routes/";

           },
           'featureunselected': function(feature) {
             document.selectform.select.value = "";
             document.selectform.selectname.value = "";
             document.selectform.selectx.value = "";
             document.selectform.selecty.value = "";
             document.selectform.selecttype.value = "";

           }
    });
}

function deactivate_all_click() {
    if(typeof(click_to_select_all)!='undefined') click_to_select_all.deactivate();
    if(typeof(click_to_copy_report_link)!='undefined') click_to_copy_report_link.deactivate();
    if(typeof(click_to_create)!='undefined') click_to_create.deactivate();
    if(typeof(click_to_copy_start_point)!='undefined') click_to_copy_start_point.deactivate();
    if(typeof(click_to_copy_end_point)!='undefined') click_to_copy_end_point.deactivate();
    if(typeof(draw)!='undefined') draw.deactivate();

}


function activate_draw() {
   vectorLayer.destroyFeatures;
   deactivate_all_click();
   draw.activate();
}

function activate_select_all() {

   deactivate_all_click();
   click_to_select_all.activate();
}


function add_click_to_select_all_controller() {
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
       /*naviagte to selection */
      if(document.selectform.selecttype.value.length>0) {
        document.getElementById("page_status").innerHTML = 'Loading ...'

        $.ajax({
          beforeSend: function (xhr){ 
            xhr.setRequestHeader("Content-Type","application/javascript");
            xhr.setRequestHeader("Accept","text/javascript");
          }, 
          type: "GET", 
          timeout: 15000,
          url: document.selectform.selecttype.value+document.selectform.select.value,
          complete: function() {
              /* complete also fires when error ocurred, so only clear if no error has been shown */
              document.getElementById("page_status").innerHTML = '';
          }
  
        });
      }
    }
  });
}



 function reset_map_controllers() {

    if(typeof(map_map)!='undefined') {

      /* disable click */
      deactivate_all_click();
      click_to_select_all.activate();

      /* disable current layer */
      vectorLayer.destroyFeatures();

   }
 }


function add_click_to_copy_start_point() {

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
      if(document.selectform.selecttype.value == "/places/") {
        document.routeform.route_startplace_id.value=document.selectform.select.value;
        document.routeform.route_startplace_name.value=document.selectform.selectname.value;
  
        /* get x,y of place, transform to WGS and write to form */
        var mapProj =  map_map.projection;
        var dstProj =  new OpenLayers.Projection("EPSG:4326");
   
        var thisPoint = new OpenLayers.Geometry.Point(document.selectform.selectx.value, document.selectform.selecty.value).transform(mapProj,dstProj);
        document.routeform.route_startplace_location.value='POINT('+thisPoint.x+" "+thisPoint.y+')';
      }
    }
  });
}

function add_click_to_copy_report_link() {

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
        if (link_item_type == '/routes/' && document.selectform.selecttype.value == "/routes/")  {
           document.getElementsByName("routeName")[0].value=document.selectform.selectname.value;
           document.getElementsByName("itemId")[0].value=document.selectform.select.value;
           document.getElementsByName("itemType")[0].value='route';
        }

        if (link_item_type == '/places/' && document.selectform.selecttype.value == "/places/")  {
           document.getElementsByName("placeName")[0].value=document.selectform.selectname.value;
           document.getElementsByName("itemId")[0].value=document.selectform.select.value;
           document.getElementsByName("itemType")[0].value='place';
        }
    }
  });
}


function add_click_to_copy_end_point() {

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
      if(document.selectform.selecttype.value == "/places/") {
        document.routeform.route_endplace_id.value=document.selectform.select.value;
        document.routeform.route_endplace_name.value=document.selectform.selectname.value;

        /* get x,y of place, transform to WGS and write to form */
        var mapProj =  map_map.projection;
        var dstProj =  new OpenLayers.Projection("EPSG:4326");

        var thisPoint = new OpenLayers.Geometry.Point(document.selectform.selectx.value, document.selectform.selecty.value).transform(mapProj,dstProj);
        document.routeform.route_endplace_location.value='POINT('+thisPoint.x+" "+thisPoint.y+')';
      }
    }
  });
}

function add_click_to_create_controller() {
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
       document.placeform.place_projection_id.value=dstProj.projCode.substr(5);

       /* convert to WGS84 and writ to location */
       var dstProj =  new OpenLayers.Projection("EPSG:4326");
       var thisPoint = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat).transform(mapProj,dstProj);

       document.placeform.place_location.value=thisPoint.x+" "+thisPoint.y;

       /* move the star */
       vectorLayer.destroyFeatures();

       var point = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat);
       var pointFeature = new OpenLayers.Feature.Vector(point,null,star_blue);
       vectorLayer.addFeatures(pointFeature);

    }
  });
}

function add_draw_controller () {

  draw = new OpenLayers.Control.DrawFeature(
      vectorLayer, OpenLayers.Handler.Path
  );
  map_map.addControl(draw);

  OpenLayers.Event.observe(document, "keydown", function(evt) {
    var handled = false;
    switch (evt.keyCode) {
        case 90: // z
            if (evt.metaKey || evt.ctrlKey) {
                draw.undo();
                handled = true;
            }
            break;
        case 89: // y
            if (evt.metaKey || evt.ctrlKey) {
                draw.redo();
                handled = true;
            }
            break;
        case 27: // esc
            draw.cancel();
            handled = true;
            break;
    }
    if (handled) {
        OpenLayers.Event.stop(evt);
    }
});
}


/* manually define styles -will need to replace this with somwthing that gets from place_types
in database eventually ... */

function create_styles() {
  star_blue = OpenLayers.Util.extend({}, layer_style);
  star_blue.strokeColor = "blue";
  star_blue.fillColor = "blue";
  star_blue.graphicName = "star";
  star_blue.pointRadius = 10;
  star_blue.strokeWidth = 3;
  star_blue.rotation = 45;
  star_blue.strokeLinecap = "butt";

  star_red = OpenLayers.Util.extend({}, layer_style);
  star_red.strokeColor = "darkred";
  star_red.fillColor = "darkred";
  star_red.graphicName = "star";
  star_red.pointRadius = 10;
  star_red.strokeWidth = 3;
  star_red.rotation = 45;
  star_red.strokeLinecap = "butt";

  star_green = OpenLayers.Util.extend({}, layer_style);
  star_green.strokeColor = "green";
  star_green.fillColor = "green";
  star_green.graphicName = "star";
  star_green.pointRadius = 10;
  star_green.strokeWidth = 3;
  star_green.rotation = 45;
  star_green.strokeLinecap = "butt";

  star_purple = OpenLayers.Util.extend({}, layer_style);
  star_purple.strokeColor = "purple";
  star_purple.fillColor = "purple";
  star_purple.graphicName = "star";
  star_purple.pointRadius = 10;
  star_purple.strokeWidth = 3;
  star_purple.rotation = 45;
  star_purple.strokeLinecap = "butt";

  line_red = OpenLayers.Util.extend({}, layer_style);
  line_red.strokeColor = "red";
  line_red.strokeWidth = 3;
  line_red.strokeLinecap = "butt";

}


// SET UP MAP VECTORLAYER FOR THE SPECIFIC SCREENS
function place_init(plloc, keep) {

  if (typeof(map_map)=='undefined') init();

  if ((keep==0) && (typeof(vectorLayer)!='undefined')) vectorLayer.destroyFeatures();

  var srcProj =  new OpenLayers.Projection("EPSG:4326");
  var mapProj =  new OpenLayers.Projection("EPSG:900913");

  if(plloc!="") {

    /* read location from form */
    feaWGS = new OpenLayers.Format.WKT().read(plloc);

    /*convert to map projectiob */
    geomMap = feaWGS.geometry.transform(srcProj, mapProj);
    pointFeature = new OpenLayers.Feature.Vector(geomMap,null,star_purple);

    /*add to map */
    vectorLayer.addFeatures(pointFeature);

  }
}

function route_init(startloc, endloc, rtline, keep) {
  if (typeof(map_map)=='undefined') init();

  if ((keep==0) && (typeof(vectorLayer)!='undefined')) vectorLayer.destroyFeatures();

  var srcProj =  new OpenLayers.Projection("EPSG:4326");
  var mapProj =  new OpenLayers.Projection("EPSG:900913");
  /* add start point */

  if(startloc!="") {
    /* read location from form */
    var feaWGS = new OpenLayers.Format.WKT().read(startloc);

    /*convert to map projectiob */
    var geomMap = feaWGS.geometry.transform(srcProj, mapProj); 
    var pointFeature = new OpenLayers.Feature.Vector(geomMap,null,star_green);

    /*add to map */
    vectorLayer.addFeatures(pointFeature);
  }
  /* add end point */
  if(endloc!="") {
  
    /* read location from form */
    feaWGS = new OpenLayers.Format.WKT().read(endloc);
  
    /*convert to map projectiob */
    geomMap = feaWGS.geometry.transform(srcProj, mapProj);
    pointFeature = new OpenLayers.Feature.Vector(geomMap,null,star_red);
  
    /*add to map */
    vectorLayer.addFeatures(pointFeature);
  }


  /* add route */
  if(rtline!="") {

    /* read location from form */
    feaWGS = new OpenLayers.Format.WKT().read(rtline);

    /*convert to map projectiob */
    geomMap = feaWGS.geometry.transform(srcProj, mapProj);
    var lineFeature = new OpenLayers.Feature.Vector(geomMap,null,line_red);

    /*add to map */
    vectorLayer.addFeatures(lineFeature);
  }

}

function place_selectPlace() {
  place_selectNothing();
  document.getElementById("placeplus").style.display="none";
  document.getElementById("placetick").style.display="block";

  vectorLayer.destroyFeatures();
  deactivate_all_click();
  click_to_create.activate();
}

function place_selectNothing() {
  document.getElementById("placeplus").style.display="block";
  document.getElementById("placetick").style.display="none";

  /* resisplay all point / lines from from */

  deactivate_all_click();


}

function route_selectStartPlace() {
  route_selectNothing();
  document.getElementById("startplaceplus").style.display="none";
  document.getElementById("startplacetick").style.display="block";
 
  deactivate_all_click();
  click_to_copy_start_point.activate();
}

function route_selectEndPlace() { 
  route_selectNothing();
  document.getElementById("endplaceplus").style.display="none";
  document.getElementById("endplacetick").style.display="block";
 

  deactivate_all_click();
  click_to_copy_end_point.activate();

}

function route_selectLocation() {
  route_selectNothing();
  document.getElementById("locationplus").style.display="none";
  document.getElementById("locationtick").style.display="block";
  vectorLayer.destroyFeatures(); 
  deactivate_all_click();
  activate_draw();

}

function route_endSelectLocation() {
  if(typeof( vectorLayer.features[0])!='undefined') {
    var wktParser=new OpenLayers.Format.WKT();
    var dstProj =  new OpenLayers.Projection("EPSG:4326");
    var mapProj =  map_map.projection;
    var distProj =  new OpenLayers.Projection("EPSG:2193");

    var lineGeomNewProj = vectorLayer.features[0].geometry.transform(mapProj,dstProj);
    var wktText = wktParser.write(new OpenLayers.Feature.Vector(lineGeomNewProj));
    var lineGeomMeterProj = lineGeomNewProj.transform(dstProj,distProj);

   /* really should do foreach an dconcatenate here ... */
    document.routeform.route_location.value=wktText;
    document.routeform.route_distance.value=lineGeomMeterProj.getLength()/1000;
  }

  route_selectNothing();
}

function route_selectNothing() {
  document.getElementById("startplaceplus").style.display="block";
  document.getElementById("startplacetick").style.display="none";
  document.getElementById("endplaceplus").style.display="block";
  document.getElementById("endplacetick").style.display="none";
  document.getElementById("locationplus").style.display="block";
  document.getElementById("locationtick").style.display="none";

  /* resisplay all point / lines from from */ 
  vectorLayer.destroyFeatures();

  deactivate_all_click();

  route_init(document.routeform.route_startplace_location.value,
              document.routeform.route_endplace_location.value,
              document.routeform.route_location.value, 0);


}
function report_selectPlace() {
  document.getElementById("placeplus").style.display="none";
  document.getElementById("placetick").style.display="block";
  document.selectform.select.value='';
  document.selectform.selectname.value='';
  link_item_type='/places/';

  deactivate_all_click();
  click_to_copy_report_link.activate();

}

function report_confirmPlace() {
  document.getElementById("placeplus").style.display="block";
  document.getElementById("placetick").style.display="none";
  
  deactivate_all_click();
}

function report_selectRoute() {
  document.getElementById("routeplus").style.display="none";
  document.getElementById("routetick").style.display="block";
  document.selectform.select.value='';
  document.selectform.selectname.value='';
  link_item_type='/routes/';

  deactivate_all_click();
  click_to_copy_report_link.activate();

}

function report_confirmRoute() {
  document.getElementById("routeplus").style.display="block";
  document.getElementById("routetick").style.display="none";
  
  deactivate_all_click();
}

function report_selectTrip() {
  document.getElementById("tripplus").style.display="none";
  document.getElementById("triptick").style.display="block";
  document.getElementById("tripSelect").disabled=false;

  document.selectform.select.value='';
  document.selectform.selectname.value='';

 document.getElementsByName("itemId")[0].value='';
  document.getElementsByName("itemType")[0].value='';
}

function report_confirmTrip() {
  document.getElementById("tripplus").style.display="block";
  document.getElementById("triptick").style.display="none";
  document.getElementById("tripSelect").disabled=true;

  document.getElementsByName("itemId")[0].value=document.getElementById("tripSelect").options.selectedIndex;
  document.getElementsByName("itemType")[0].value='trip';

  
}


// MISCELANEOUS PAGE EVENT HANDLING THAT HAVE NOTHING TO DO WITH THE MAP

// MISCELANEOUS PAGE EVENT HANDLING THAT HAVE NOTHING TO DO WITH THE MAP

function linkHandler(entity_name) {
    /* close the dropdown */
    $('.dropdown').removeClass('open');

    /* show 'loading ...' */
    document.getElementById("page_status").innerHTML = 'Loading ...'

    /* register on complete ... */
    $('#'+entity_name).bind('ajax:complete', function() {
        /* complete also fires when error ocurred, so only clear if no error has been shown */
         document.getElementById("page_status").innerHTML = '';
    });

    /* set timeoput and register handler */
    $(function() {
     $.rails.ajax = function (options) {
      if (!options.timeout) {
         options.timeout = 15000;
         }
      return $.ajax(options);
     };
    }); 

   
 
}
   function clickplus(divname) {
     document.getElementById(divname).style.display = 'block';
     document.getElementById(divname+"plus").style.display="none";
     document.getElementById(divname+"minus").style.display="block";
   }


   function clickminus(divname) {
     document.getElementById(divname).style.display = 'none';
     document.getElementById(divname+"plus").style.display="block";
     document.getElementById(divname+"minus").style.display="none";
   }

   function updatePlace(buttonName) {
     placesStale=true;
     linkHandler(buttonName);
   }

   function updateRoute(buttonName) {
     routesStale=true;
     linkHandler(buttonName); 
   }

   function updateTrip(buttonName) {
    tripsStale=true;
     linkHandler(buttonName);

   }

   function cutItem(itemId) {
      document.moveForm.cutFrom.value = itemId;
      var buttonArray = document.getElementsByClassName("pastebutton");

      for(var i = (buttonArray.length - 1); i >= 0; i--)
      {
          buttonArray[i].style.display = "block";
      }

      var cutArray = document.getElementsByClassName("cutbutton");

      for(i = (cutArray.length - 1); i >= 0; i--)
      {
          cutArray[i].style.display = "none";
      }
      deleteArray = document.getElementsByClassName("deletebutton");

      for(i = (deleteArray.length - 1); i >= 0; i--)
      {
          deleteArray[i].style.display = "none";
      }

      // enable the one delete and disable the paste
      document.getElementById("deleteItem"+itemId).style.display = 'block';
      document.getElementById("pasteItem"+itemId).style.display = 'none';

      return false;
   }

   function pasteItem(orderNo) {
     document.moveForm.pasteAfter.value = orderNo;
   }

   function update_title(title) {
     document.getElementById('logo').innerHTML='Route Guides'+title;

}
   function WKTtoGPX() {

     var wktp = new OpenLayers.Format.WKT();
     var gpxp = new OpenLayers.Format.GPX();

     var fea = wktp.read(document.routeform.route_location.value);
     document.routeform.gpxfield.value=gpxp.write(fea[0]);
}
   function GPXtoWKT() {
     var gpxProj =  new OpenLayers.Projection("EPSG:4326");
     var distProj =  new OpenLayers.Projection("EPSG:2193");


     var wktp = new OpenLayers.Format.WKT();
     var gpxp = new OpenLayers.Format.GPX();

     if (document.routeform.gpxfield.value) {
       var fea = gpxp.read(document.routeform.gpxfield.value);
       if (fea.length>0) {
         document.routeform.route_location.value=wktp.write(fea[0]);

         var lineGeomMeterProj = fea[0].geometry.transform(gpxProj,distProj);
         document.routeform.route_distance.value=lineGeomMeterProj.getLength()/1000;
         document.routeform.route_datasource.value="Uploaded from GPS";
       }
     }
}

   function enableGpx() {
     document.getElementById("gpxplus").style.display="none";
     document.getElementById("gpxtick").style.display="block";
     document.getElementById("gpxfield").style.display="block";
}

   function copyGpx() {
     
     GPXtoWKT();
     document.getElementById("gpxplus").style.display="block";
     document.getElementById("gpxtick").style.display="none";
     document.getElementById("gpxfield").style.display="none";

     // redraw map
     route_init(document.routeform.route_startplace_location.value,
              document.routeform.route_endplace_location.value,
              document.routeform.route_location.value, 0);

}
