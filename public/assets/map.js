var map_map;

            // we want opaque external graphics and non-opaque internal graphics

var vectorLayer;
var renderer;

var layer_style;
var click_to_select;
var click_to_create;
var style_blue;
var style_hut;
var style_pt_default;
var pt_styleMap;
var select;

function init(){
  if(typeof(map_map)=='undefined') {

    /* explicityly define the projections we will use */
    Proj4js.defs["EPSG:2193"] = "+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
    Proj4js.defs["EPSG:900913"] = "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs";

    /* define our point styles */
    create_styles();

    map_map = new OpenLayers.Map( 'map_map', {
            displayProjection: new OpenLayers.Projection("EPSG:2193"),
            projection: new OpenLayers.Projection("EPSG:900913")
    } );



    renderer = OpenLayers.Util.getParameters(window.location.href).renderer;
    renderer = (renderer) ? [renderer] : OpenLayers.Layer.Vector.prototype.renderers;

    layer_style = OpenLayers.Util.extend({}, OpenLayers.Feature.Vector.style['default']);
    layer_style.fillOpacity = 0.2;
    layer_style.graphicOpacity = 1;

    var extent = new OpenLayers.Bounds(19342958.233236, -5095432.4834721,  19551784.194512, -5000803.4424551);
    var test_g_wmts_layer = new OpenLayers.Layer.WMTS({
        name: "nztopomaps.com",
        url: "http://wharncliffe.co.nz/mapcache/wmts/",
        layer: 'test',
        matrixSet: 'g',
        format: 'image/png',
        style: 'default',
        gutter:0,buffer:0,isBaseLayer:true,transitionEffect:'resize',
        resolutions:[156543.03392804099712520838,78271.51696402048401068896,39135.75848201022745342925,19567.87924100512100267224,9783.93962050256050133612,4891.96981025128025066806,2445.98490512564012533403,1222.99245256282006266702,611.49622628141003133351,305.74811314070478829308,152.87405657035250783338,76.43702828517623970583,38.21851414258812695834,19.10925707129405992646,9.55462853564703173959,4.77731426782351586979,2.38865713391175793490,1.19432856695587897633,0.59716428347793950593],
        zoomOffset:0,
        units:"m",
        maxExtent: new OpenLayers.Bounds(-20037508.342789,-20037508.342789,20037508.342789,20037508.342789),
        projection: new OpenLayers.Projection("EPSG:900913".toUpperCase()),
        sphericalMercator: true
      }
    );

            
    places_layer = new OpenLayers.Layer.Vector("Places", {
                    strategies: [new OpenLayers.Strategy.BBOX()],
                    protocol: new OpenLayers.Protocol.WFS({
                        url:  "http://wharncliffe.co.nz/cgi-bin/mapserv?map=/ms4w/apps/matts_app/htdocs/example1-5.map",
                        featureType: "places",
                        extractAttributes: true
                    }),
                    styleMap: pt_styleMap
                }); 

   /* copy selected feature to div */
    places_layer.events.on({
        'featureselected': function(feature) {
	     var f = places_layer.selectedFeatures.pop();
             document.selectform.select.value = "/places/"+f.attributes.id;
           },
           'featureunselected': function(feature) {
             document.selectform.select.value = "";
           }
    });

 
 //callback after a layer has been loaded in openlayers
    places_layer.events.register("loadend", places_layer, function() { 
           tooltip();
    });

    map_map.addLayer(test_g_wmts_layer);
    map_map.addLayer(places_layer);


    map_map.zoomToExtent(extent);
    map_map.addControl(new OpenLayers.Control.LayerSwitcher());
    map_map.addControl(new OpenLayers.Control.MousePosition());
    
    // Create a select feature control and add it to the map.
    select = new OpenLayers.Control.SelectFeature(places_layer, {hover: true});
    map_map.addControl(select);
    select.activate();
   //callback for moveend event - fix tooltips
    map_map.events.register("moveend", map_map, function() {
        tooltip();
    });

    //callback for moveend event - fix tooltips
    map_map.events.register("zoomend", map_map, function() {
        tooltip();
    });

    /* create click controllers*/
    add_click_to_select_controller();
    click_to_select = new OpenLayers.Control.Click();
    map_map.addControl(click_to_select);
    add_click_to_create_controller();
    click_to_create = new OpenLayers.Control.Click();
    map_map.addControl(click_to_create);

    /* by default, activate only xclick_to_select */
    click_to_select.activate();

  }
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
      $.ajax({
        beforeSend: function (xhr){ 
          xhr.setRequestHeader("Content-Type","application/javascript");
          xhr.setRequestHeader("Accept","text/javascript");
        }, 
        type: "GET", 
        url: document.selectform.select.value
      });
    }
  });
}
 function reset_map_controllers() {

    if(typeof(map_map)!='undefined') {

      /* disable click */
      if(click_to_create.active) {
        click_to_create.deactivate();
        click_to_select.activate();
      }

     /* disable current layer */
     vectorLayer.destroyfeatures();
   }
 }

/* tooltip functionality */
 function tooltip(){
            
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
       var pointFeature = new OpenLayers.Feature.Vector(point,null,style_blue);
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
}

