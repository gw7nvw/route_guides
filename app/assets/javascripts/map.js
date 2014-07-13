
var map_map;

            // we want opaque external graphics and non-opaque internal graphics

var vectorLayer;
var renderer;

var layer_style;
var click_to_select;
var click_to_copy_start_point;
var click_to_copy_end_point;
var click_to_create;
var star_blue;
var style_hut;
var style_pt_default;
var pt_styleMap;
var select;
var draw;
var star_purple;
var star_red;
var star_green;
var star_blue;
var line_red;
var statusMessage = 0;
var autoPlacesOff = false;
var placesStale=false;
var routesStale=false;
var tripsStale=false;

function init(){
  if(typeof(map_map)=='undefined') {

    /* explicityly define the projections we will use */
    Proj4js.defs["EPSG:2193"] = "+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
    Proj4js.defs["EPSG:900913"] = "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs";

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
    var test_g_wmts_layer = new OpenLayers.Layer.WMTS({
        name: "nztopomaps.com",
        url: "http://routeguides.co.nz/mapcache/wmts/",
        layer: 'test',
        matrixSet: 'g',
        format: 'image/png',
        style: 'default',
        gutter:0,buffer:0,isBaseLayer:true,transitionEffect:'resize',
      /*  resolutions:[156543.03392804099712520838,78271.51696402048401068896,39135.75848201022745342925,19567.87924100512100267224,9783.93962050256050133612,4891.96981025128025066806,2445.98490512564012533403,1222.99245256282006266702,611.49622628141003133351,305.74811314070478829308,152.87405657035250783338,76.43702828517623970583,38.21851414258812695834,19.10925707129405992646,9.55462853564703173959,4.77731426782351586979,2.38865713391175793490,1.19432856695587897633,0.59716428347793950593],*/
        /*zoomOffset:0,*/
        resolutions:[2445.98490512564012533403,1222.99245256282006266702,611.49622628141003133351,305.74811314070478829308,152.87405657035250783338,76.43702828517623970583,38.21851414258812695834,19.10925707129405992646,9.55462853564703173959],
        zoomOffset:6,
        units:"m",
        maxExtent: new OpenLayers.Bounds(-20037508.342789,-20037508.342789,20037508.342789,20037508.342789),
        projection: new OpenLayers.Projection("EPSG:900913".toUpperCase()),
        sphericalMercator: true
      }
    );

    places_layer_add();

    routes_layer = new OpenLayers.Layer.Vector("routes", {
                    strategies: [new OpenLayers.Strategy.BBOX()],
                    protocol: new OpenLayers.Protocol.WFS({
                        url:  "http://routeguides.co.nz/cgi-bin/mapserv?map=/ms4w/apps/matts_app/htdocs/routes.map",
                        featureType: "routes",
                        extractAttributes: true
                    }),
                    styleMap: pt_styleMap
                });

 //callback after a layer has been loaded in openlayers
    routes_layer.events.register("loadend", routes_layer, function() {
           tooltip_routes();
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

    map_map.addLayer(test_g_wmts_layer);
    map_map.addLayer(places_layer);
    map_map.addLayer(routes_layer);

    map_map.zoomToExtent(extent); 
    map_map.addControl(new OpenLayers.Control.LayerSwitcher());
    map_map.addControl(new OpenLayers.Control.MousePosition());
    
    // Create a select feature control and add it to the map.
    select = new OpenLayers.Control.SelectFeature([places_layer, routes_layer], {hover: true});
    map_map.addControl(select);
    select.activate();

   //callback for moveend event - fix tooltips
    map_map.events.register("moveend", map_map, function() {
 //       tooltip_routes();
        tooltip_places();
    });

    //callback for moveend event - fix tooltips
    map_map.events.register("zoomend", map_map, function() {
   //     tooltip_routes();
       var x = map_map.getZoom();
        
        if( x > 9) {
            map_map.zoomTo(9);
        }
        if( x < 0) {
            map_map.zoomTo(0);
        }
        // hide places above 7 zoom (too much data).  Turn back on if we drop beloiw 
        if( x < 2) {
            places_layer.setVisibility(false);
            autoPlacesOff=true;
       } else {
            if (autoPlacesOff==true) {
                places_layer.setVisibility(true);
            }
       }
        tooltip_places();
    });

    vectorLayer = new OpenLayers.Layer.Vector("Current feature", {
                style: layer_style,
                renderers: renderer,
                projection: new OpenLayers.Projection("EPSG:900913".toUpperCase())
            });
    map_map.addLayer(vectorLayer);

   /* arrange layer order */
//   map_map.setLayerIndex(test_g_wmts_layer,100);
 //  map_map.setLayerIndex(places_layer,200);
  // map_map.setLayerIndex(routes_layer,300);
   //map_map.setLayerIndex(vector_layer,400);
//
   //map_map.redraw();

    /* create click controllers*/
    add_click_to_select_controller();
    click_to_select = new OpenLayers.Control.Click();
    map_map.addControl(click_to_select);

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
    click_to_select.activate();

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
 //callback after a layer has been loaded in openlayers
    places_layer.events.register("loadend", places_layer, function() { 
           tooltip_places();
    });
}
function deactivate_all_click() {
    if(typeof(click_to_select)!='undefined') click_to_select.deactivate();
    if(typeof(click_to_create)!='undefined') click_to_create.deactivate();
    if(typeof(click_to_copy_start_point)!='undefined') click_to_copy_start_point.deactivate();
    if(typeof(click_to_copy_end_point)!='undefined') click_to_copy_end_point.deactivate();
    if(typeof(draw)!='undefined') draw.deactivate();

}

function add_click_to_select_controller() {
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
// window.location.replace(document.getElementById('selected').innerHTML);
//      $('#right_panel').load(document.getElementById('selected').innerHTML);
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
  });
}
 function reset_map_controllers() {

    if(typeof(map_map)!='undefined') {

      /* disable click */
      if(click_to_create.active) {
        deactivate_all_click();
        click_to_select.activate();
      }

     /* disable current layer */
     vectorLayer.destroyfeatures();
   }
 }

/* tooltip functionality */
 function tooltip_places(){
            
            var tooltips = document.getElementsByTagName("title");
            var tooltip = document.getElementById("tooltip");

          for (var i = 0; i < tooltips.length; i++) {
            tooltips.item(i).parentNode.addEventListener('mouseover', function(e) {
              showTip(this,xy(e));
            }, true);
            tooltips.item(i).parentNode.addEventListener('mouseout', function() {
              hideTip(this);
            }, true);
          }

          function showTip(element,pos) {
            
            var title = element.attributes.title.value; //many different ways to grab this
            var offset = 7;
            var top = pos[1]+offset+'px';
            var left = pos[0]+offset+'px';
            tooltip.style.top = top;
            tooltip.style.left = left;
            tooltip.textContent = title;
            tooltip.style.display = 'block';
          }

          function hideTip(element) {
            tooltip.style.display = 'none';
          }

          function xy(e) {
            if (!e) var e = window.event;
            if (e.pageX || e.pageY) {
              return [e.pageX,e.pageY]
            } else if (e.clientX || e.clientY) {
              return [e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft,e.clientY + document.body.scrollTop + document.documentElement.scrollTop];
            }
            return [0,0]
          }

        }

/* tooltip functionality */
 function tooltip_routes(){

            var tooltips = document.getElementsByTagName("title");
            var tooltip = document.getElementById("tooltip");

          for (var i = 0; i < tooltips.length; i++) {
            tooltips.item(i).parentNode.addEventListener('mouseover', function(e) {
              showTip(this,xy(e));
            }, true);
            tooltips.item(i).parentNode.addEventListener('mouseout', function() {
              hideTip(this);
            }, true);
          }

          function showTip(element,pos) {

            var title = element.attributes.title.value; //many different ways to grab this
            var offset = 7;
            var top = pos[1]+offset+'px';
            var left = pos[0]+offset+'px';
            tooltip.style.top = top;
            tooltip.style.left = left;
            tooltip.textContent = title;
            tooltip.style.display = 'block';
          }

          function hideTip(element) {
            tooltip.style.display = 'none';
          }

          function xy(e) {
            if (!e) var e = window.event;
            if (e.pageX || e.pageY) {
              return [e.pageX,e.pageY]
            } else if (e.clientX || e.clientY) {
              return [e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft,e.clientY + document.body.scrollTop + document.documentElement.scrollTop];
            }
            return [0,0]
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
      document.routeform.route_startplace_id.value=document.selectform.select.value;
      document.routeform.route_startplace_name.value=document.selectform.selectname.value;

      /* get x,y of place, transform to WGS and write to form */
      var mapProj =  map_map.projection;
      var dstProj =  new OpenLayers.Projection("EPSG:4326");
 
      var thisPoint = new OpenLayers.Geometry.Point(document.selectform.selectx.value, document.selectform.selecty.value).transform(mapProj,dstProj);
      document.routeform.route_startplace_location.value='POINT('+thisPoint.x+" "+thisPoint.y+')';

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
      document.routeform.route_endplace_id.value=document.selectform.select.value;
      document.routeform.route_endplace_name.value=document.selectform.selectname.value;

      /* get x,y of place, transform to WGS and write to form */
      var mapProj =  map_map.projection;
      var dstProj =  new OpenLayers.Projection("EPSG:4326");

      var thisPoint = new OpenLayers.Geometry.Point(document.selectform.selectx.value, document.selectform.selecty.value).transform(mapProj,dstProj);
      document.routeform.route_endplace_location.value='POINT('+thisPoint.x+" "+thisPoint.y+')';

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
       document.placeform.place_projn.value=dstProj;

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

/* manually define styles -will need to replace this with somwthing that gets from place_types
in database eventually ... */

function create_styles() {
    style_pt_default = {strokeColor: "red", strokeOpacity: "0.7", strokeWidth: 3, cursor: "pointer", pointRadius: 4, fillColor: "red", graphicName: "circle", title: '${name}'};

    var sty = OpenLayers.Util.applyDefaults(style_pt_default, OpenLayers.Feature.Vector.style["default"]);
    pt_styleMap = new OpenLayers.StyleMap({
            'default': sty,
            'select': {strokeColor: "pink", fillColor: "pink"}
        });
    pt_styleMap.styles['default'].addRules([
        new OpenLayers.Rule({
            filter: new OpenLayers.Filter.Comparison({
            type: OpenLayers.Filter.Comparison.EQUAL_TO, property: "place_type", value: "Hut"
            }),
            symbolizer: {strokeColor: "blue", fillColor: "blue"}
        }),
        new OpenLayers.Rule({
            elseFilter: true
        })
    ]);

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

function update_title(title) {
  document.getElementById('logo').innerHTML='Route Guides'+title;

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


function activate_draw() {
   vectorLayer.destroyFeatures;
   deactivate_all_click();
   draw.activate();
}

function place_init() {

  if (typeof(map_map)=='undefined') init();

  vectorLayer.destroyFeatures();

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
  var pointFeature = new OpenLayers.Feature.Vector(point,null,star_purple);
  vectorLayer.addFeatures(pointFeature);

  /* turn on click to get coords */
  if(!document.placeform.place_x.disabled) {
     deactivate_all_click();
     click_to_create.activate();
  }
}

function route_init() {
    if (typeof(map_map)=='undefined') init();

  vectorLayer.destroyFeatures();

  var srcProj =  new OpenLayers.Projection("EPSG:4326");
  var mapProj =  new OpenLayers.Projection("EPSG:900913");
  /* add start point */

  if(document.routeform.route_startplace_location.value!="") {
  /* read location from form */
  var feaWGS = new OpenLayers.Format.WKT().read(document.routeform.route_startplace_location.value);

  /*convert to map projectiob */
  var geomMap = feaWGS.geometry.transform(srcProj, mapProj); 
  var pointFeature = new OpenLayers.Feature.Vector(geomMap,null,star_green);

  /*add to map */
  vectorLayer.addFeatures(pointFeature);
}
  /* add end point */
  if(document.routeform.route_endplace_location.value!="") {

  /* read location from form */
  feaWGS = new OpenLayers.Format.WKT().read(document.routeform.route_endplace_location.value);

  /*convert to map projectiob */
  geomMap = feaWGS.geometry.transform(srcProj, mapProj);
  pointFeature = new OpenLayers.Feature.Vector(geomMap,null,star_red);

  /*add to map */
  vectorLayer.addFeatures(pointFeature);
}


  /* add route */
  if(document.routeform.route_location.value!="") {

  /* read location from form */
  feaWGS = new OpenLayers.Format.WKT().read(document.routeform.route_location.value);

  /*convert to map projectiob */
  geomMap = feaWGS.geometry.transform(srcProj, mapProj);
  var lineFeature = new OpenLayers.Feature.Vector(geomMap,null,line_red);

  /*add to map */
  vectorLayer.addFeatures(lineFeature);
}

}

function route_selectStartPlace() {
  route_selectNothing();
  document.getElementById("startplaceplus").width=0;
  document.getElementById("startplacetick").width=16;
 
  deactivate_all_click();
  click_to_copy_start_point.activate();
}

function route_selectEndPlace() { 
  route_selectNothing();
  document.getElementById("endplaceplus").width=0;
  document.getElementById("endplacetick").width=16;
 

  deactivate_all_click();
  click_to_copy_end_point.activate();

}

function route_selectLocation() {
  route_selectNothing();
  document.getElementById("locationplus").width=0;
  document.getElementById("locationtick").width=16;
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
  document.getElementById("startplaceplus").width=16;
  document.getElementById("startplacetick").width=0;
  document.getElementById("endplaceplus").width=16;
  document.getElementById("endplacetick").width=0;
  document.getElementById("locationplus").width=16;
  document.getElementById("locationtick").width=0;

  /* resisplay all point / lines from from */ 
  vectorLayer.destroyFeatures();

  deactivate_all_click();

  route_init();

}

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
     document.getElementById(divname+"plus").width=0;
     document.getElementById(divname+"minus").width=16;
   }


   function clickminus(divname) {
     document.getElementById(divname).style.display = 'none';
     document.getElementById(divname+"plus").width=16;
     document.getElementById(divname+"minus").width=0;
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

