OpenLayers.IMAGE_RELOAD_ATTEMPTS = 3;
OpenLayers.Util.onImageLoadErrorColor = "transparent";
var map_map;
var mapBounds = new OpenLayers.Bounds(748961,3808210, 2940563,  6836339);
var mapMinZoom = 0;
var mapMaxZoom = 10;
var map_pinned=false;
var map_size=1;

var vectorLayer;
var places_layer;
var routes_layer;
var catchments_layer;
var routes_simple_layer;
var docland_layer;
var docland_simple_layer;
var renderer;

var layer_style;
var pt_styleMap;
var rt_styleMap;
var ca_styleMap;
var style_pt_default;
var style_rt_default;
var star_purple;
var star_red;
var star_green;
var star_blue;
var line_red;
var  containerWidth;
var  nbpanels;
var  padding;
var currentPercentage=0.45

var show_route;
var show_docland;
var show_accomodation;
var show_roadend;
var show_summit;
var show_scenic;
var show_crossing
var show_other;

var select;
var click_to_select_all;
var click_to_copy_start_point;
var click_to_copy_link;
var click_to_copy_end_point;
var click_to_create;
var select_catchment;
var link_item_type="test";
var draw;

var statusMessage = 0;
var autoPlacesOff = false;
var placesStale=false;
var routesStale=false;
var tripsStale=false;

var itemToCut;
var positionToPaste;

var mapset="mapspast";

var pin_button;
var pan_button;
var info_button;
var select_point_button;
var select_line_button;
var draw_point_button;
var draw_line_button;
var disabled_button;
var route_class="routetype"
var current_proj="2193"
var current_projname="NZTM2000"
var current_projdp=0;

/* keep trtack of current page, and trigger refresh if we 'pop'
   a different page (back/forward buttons) */
if (typeof(lastUrl)=='undefined')  var lastUrl=document.URL;
window.onpopstate = function(event)  {
  if (document.URL != lastUrl) location.reload();
};

function init_mapspast() {
  mapset="mapspast";
  currentextent=mapBounds;
  if(typeof(map_map)!='undefined') {
     var currentextent=map_map.getExtent()
     map_map.destroy();
  }
  do_init();
  apply_current_filters();
  map_map.zoomToExtent(currentextent);
}

function init_linz() {
  mapset="linz";
  currentextent=mapBounds;
  if(typeof(map_map)!='undefined') {
     currentextent=map_map.getExtent()
     map_map.destroy();
  }
  do_init();
  apply_current_filters();
  map_map.zoomToExtent(currentextent);
  map_map.zoomIn();
}
function init(){
  if(typeof(map_map)=='undefined') {
    map_show_default();
    do_init();
  }
}

function do_init(){
  init_styles();

//containerWidth= $("#main_page").width()-25;
//nbpanels = 2;
//padding = 5;
  //resizable div
  window.onresize = function()
  {
   setTimeout( function() { map_map.updateSize();}, 1000);
 //  containerWidth= $("#main_page").width()-25;
 //  var currentWidth = $("#left_panel").width();
 //  $("#right_panel").width(containerWidth*(1-currentPercentage));
 //  $("#right_panel").css('margin-left', (containerWidth*currentPercentage+padding*2)+'px' );
 //  $("#left_panel").width(containerWidth*currentPercentage);
  } 
//  $(".panel").width( (containerWidth / nbpanels) - (nbpanels * padding - 2 * padding));

  //$(".panel").resizable({
  //  handles: 'e',
  //  resize: function(event, ui){
  //    var currentWidth = ui.size.width;
  //    currentPercentage=currentWidth/containerWidth;
  //    // set the content panel width
  //    $("#right_panel").width(containerWidth*(1-currentPercentage));
  //    $("#right_panel").css('margin-left', currentWidth+padding*2+'px' );
  //    $(this).width(currentWidth);
  // }
 // });
    /* explicityly define the projections we will use */
    Proj4js.defs["EPSG:2193"] = "+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
    Proj4js.defs["EPSG:900913"] = "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs";
    Proj4js.defs["EPSG:27200"] = "+proj=nzmg +lat_0=-41 +lon_0=173 +x_0=2510000 +y_0=6023150 +ellps=intl +datum=nzgd49 +units=m +no_defs";
    Proj4js.defs["ESPG:4326"] = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs '
    Proj4js.defs["EPSG:27291"] = "+proj=tmerc +lat_0=-39 +lon_0=175.5 +k=1 +x_0=274319.5243848086 +y_0=365759.3658464114 +ellps=intl +datum=nzgd49 +to_meter=0.9143984146160287 +no_defs";
    Proj4js.defs["EPSG:27292"] = "+proj=tmerc +lat_0=-44 +lon_0=171.5 +k=1 +x_0=457199.2073080143 +y_0=457199.2073080143 +ellps=intl +datum=nzgd49 +to_meter=0.9143984146160287 +no_defs";

	    /* define our point styles */
	    create_styles();

    var mapspast_options = {
            projection: new OpenLayers.Projection("EPSG:2193"),
	    displayProjection: new OpenLayers.Projection("EPSG:"+current_proj),
	    units: "m",
      maxResolution: 4891.969809375,
      numZoomLevels: 11,
      maxExtent: new OpenLayers.Bounds(-20037508, -20037508, 20037508, 20037508.34)
    };
    var linz_options = {
      projection: new OpenLayers.Projection("EPSG:2193"),
            displayProjection: new OpenLayers.Projection("EPSG:"+current_proj),
            units: "m",
      resolutions: [8960, 4480, 2240, 1120, 560, 280, 140, 70, 28, 14, 7, 2.8, 1.4, 0.7, 0.28, 0.14, 0.07],
      numZoomLevels: 11,
      maxExtent:  new OpenLayers.Bounds(827933.23, 3729820.29, 3195373.59, 7039943.58)
    };

    if (mapset=="mapspast") {
      map_map = new OpenLayers.Map('map_map', mapspast_options);
    } else {
      map_map = new OpenLayers.Map('map_map', linz_options);
    }


    renderer = OpenLayers.Util.getParameters(window.location.href).renderer;
    renderer = (renderer) ? [renderer] : OpenLayers.Layer.Vector.prototype.renderers;

    layer_style = OpenLayers.Util.extend({}, OpenLayers.Feature.Vector.style['default']);
    layer_style.fillOpacity = 0.2;
    layer_style.graphicOpacity = 1;
    layer_style.strokeWidth = 2;
    layer_style.strokeColor = "red";
    layer_style.fillColor = "red";

    var extent=new OpenLayers.Bounds(545967,  3739728,  2507647, 6699370);
//    var extent=new OpenLayers.Bounds(827933.23, 3729820.29, 3195373.59, 7039943.58)

    places_layer_add();
    places_layer.setVisibility(false);

    routes_layer_add();
    routes_layer.setVisibility(false);

    routes_simple_layer_add();

    catchments_layer_add();
    catchments_layer.setVisibility(false);

    docland_simple_layer_add();
    docland_simple_layer.setVisibility(false);
    docland_layer_add();
    docland_layer.setVisibility(false);

    if (mapset=="mapspast") {

      var basemap_layer =  new OpenLayers.Layer.TMS( "NZTM Topo 2009", "http://au.mapspast.org.nz/topo50/",
        {    
             type: 'png', 
             getURL: overlay_getTileURL,
             isBaseLayer: true,
             tileOrigin: new OpenLayers.LonLat(0,-20037508),
             displayInLayerSwitcher:true
         });

      var nzms1989_layer =  new OpenLayers.Layer.TMS( "NZMS1/260 1989", "http://au.mapspast.org.nz/nzms-1989/",
        {    
             type: 'png', 
             getURL: overlay_getTileURL,
             isBaseLayer: true,
             tileOrigin: new OpenLayers.LonLat(0,-20037508),
             displayInLayerSwitcher:true
         });
      var nzms1969_layer =  new OpenLayers.Layer.TMS( "NZMS1 1969", "http://au.mapspast.org.nz/nzms-1969/",
        {    
             type: 'png', 
             getURL: overlay_getTileURL,
             isBaseLayer: true,
             tileOrigin: new OpenLayers.LonLat(0,-20037508),
             displayInLayerSwitcher:true
         });
    
      var nzms1979_layer =  new OpenLayers.Layer.TMS( "NZMS1 1979", "http://au.mapspast.org.nz/nzms-1979/",
        {    
             type: 'png', 
             getURL: overlay_getTileURL,
             isBaseLayer: true,
           // tileOrigin: new OpenLayers.LonLat(0,-20037508),
             displayInLayerSwitcher:true
         });

      var nzms1999_layer =  new OpenLayers.Layer.TMS( "NZMS260 1999", "http://au.mapspast.org.nz/nzms260-1999/",
        {
             type: 'png',
             getURL: overlay_getTileURL,
             isBaseLayer: true,
           // tileOrigin: new OpenLayers.LonLat(0,-20037508),
             displayInLayerSwitcher:true
         });

      var nzms1959_layer =  new OpenLayers.Layer.TMS( "NZMS1 1959", "http://au.mapspast.org.nz/nzms-1959/",
        {
             type: 'png',
             getURL: overlay_getTileURL,
             isBaseLayer: true,
           // tileOrigin: new OpenLayers.LonLat(0,-20037508),
             displayInLayerSwitcher:true
         });

      map_map.addLayer(basemap_layer);
      map_map.addLayer(nzms1999_layer);
      map_map.addLayer(nzms1989_layer);
      map_map.addLayer(nzms1979_layer);
      map_map.addLayer(nzms1969_layer);
      map_map.addLayer(nzms1959_layer);

    } else {
      var linztopo_layer =  new OpenLayers.Layer.TMS( "(LINZ) Topo50 latest", "http://tiles-a.data-cdn.linz.govt.nz/services;key=d8c83efc690a4de4ab067eadb6ae95e4/tiles/v4/layer=767/EPSG:2193/",
        {
             type: 'png',
             getURL: overlay_getLinzTileURL,
             isBaseLayer: true,
             tileOrigin: new OpenLayers.LonLat(-1000000,10000000),
             displayInLayerSwitcher:true,
             rowSign: 1
         });
      var air_layer =  new OpenLayers.Layer.TMS( "(LINZ) Airphoto latest", "http://tiles-a.data-cdn.linz.govt.nz/services;key=d8c83efc690a4de4ab067eadb6ae95e4/tiles/v4/set=2/EPSG:2193/",
        {
             type: 'png',
             getURL: overlay_getLinzTileURL,
             isBaseLayer: true,
             tileOrigin: new OpenLayers.LonLat(-1000000,10000000),
             displayInLayerSwitcher:true,
             rowSign: 1
         });

      map_map.addLayer(linztopo_layer);
      map_map.addLayer(air_layer);
    }

    map_map.addLayer(places_layer);
    map_map.addLayer(routes_layer);
    map_map.addLayer(routes_simple_layer);
    map_map.addLayer(catchments_layer);
    map_map.addLayer(docland_layer);
    map_map.addLayer(docland_simple_layer);

    map_map.zoomToExtent(extent); 
    map_map.addControl(new OpenLayers.Control.MousePosition({
        prefix: current_projname+": ",
        numDigits: current_projdp}));
    map_map.addControl(new OpenLayers.Control.Scale());
  
    var layer_button = new OpenLayers.Control.Button({
      displayClass: 'olControlLayers',
      trigger: mapLayers,
      title: 'Select basemap'
    });
    var filter_button = new OpenLayers.Control.Button({
      displayClass: 'olControlFilter',
      trigger: mapFilter,
      title: 'Filter places / routes shown on map'
    });
    var key_button = new OpenLayers.Control.Button({
      displayClass: 'olControlKey',
      trigger: mapKey,
      title: 'Show legend / configure map'
    });
    var centre_button = new OpenLayers.Control.Button({
      displayClass: 'olControlCentre',
      trigger: map_centre,
      title: 'Centre map on current item'
    });
    pin_button = new OpenLayers.Control.Button({
      displayClass: 'olControlPin',
      trigger: pin_map,
      title: 'Pin the map (disable centre on selected place/route)'
    });
    pan_button = new OpenLayers.Control.Button({
      displayClass: 'olControlPan',
      trigger: select_box,
      title: 'Enable map panning (disables box-select)'
    });
    box_button = new OpenLayers.Control.Button({
      displayClass: 'olControlBox',
      trigger: select_box,
      title: 'Enable box-select (disables panning)'
    });
    print_button = new OpenLayers.Control.Button({
      displayClass: 'olControlPrint',
      trigger: print_map,
      title: 'Save / print the current map'
    });
    info_button = new OpenLayers.Control.Button({
      displayClass: 'olControlInfo',
      title: 'Current mouse action: click on map displays info on place/route segment'
    });
    select_point_button = new OpenLayers.Control.Button({
      displayClass: 'olControlSelectPoint',
      title: 'Current mouse action: click on map selects a place'
    });
    select_line_button = new OpenLayers.Control.Button({
      displayClass: 'olControlSelectLine',
      title: 'Current mouse action: click on map selects a route'
    });
    draw_point_button = new OpenLayers.Control.Button({
      displayClass: 'olControlDrawPoint',
      title: 'Current mouse action: click on map draws a place'
    });
    draw_line_button = new OpenLayers.Control.Button({
      displayClass: 'olControlDrawLine',
      title: 'Current mouse action: click on map draws a route'
    });
    disabled_button = new OpenLayers.Control.Button({
      displayClass: 'olControlDisabled',
      title: 'Current mouse action: click on map is currently disabled'
    });

      var panel = new OpenLayers.Control.Panel({
          createControlMarkup: function(control) {
              var button = document.createElement('button'),
                  iconSpan = document.createElement('span'),
                  textSpan = document.createElement('span');
              iconSpan.innerHTML = '&nbsp;';
              button.appendChild(iconSpan);
              if (control.text) {
                  textSpan.innerHTML = control.text;
              }
              button.appendChild(textSpan);
              return button;
         }
      });

    panel.addControls([info_button, select_point_button, select_line_button, draw_point_button, draw_line_button, disabled_button, layer_button, filter_button, key_button, centre_button, pin_button, pan_button, box_button, print_button]);
    map_map.addControl(panel);
    pan_button.panel_div.style.display="none";
    info_button.panel_div.style.display="none";
    select_point_button.panel_div.style.display="none";
    select_line_button.panel_div.style.display="none";
    draw_point_button.panel_div.style.display="none";
    draw_line_button.panel_div.style.display="none";
    info_button.panel_div.style.border="2px solid lightgreen";
    select_point_button.panel_div.style.border="2px solid lightgreen";
    select_line_button.panel_div.style.border="2px solid lightgreen";
    draw_point_button.panel_div.style.border="2px solid lightgreen";
    draw_line_button.panel_div.style.border="2px solid lightgreen";
 
//    var switcherControl = new OpenLayers.Control.LayerSwitcher();
//    map_map.addControl(switcherControl);
 
    // Create a select feature control and add it to the map.
    select = new OpenLayers.Control.SelectFeature([places_layer, routes_layer], {
                 clickout: true, toggle: false,
                        multiple: false, hover: true,
                        toggleKey: "ctrlKey", // ctrl key removes from selection
                        multipleKey: "shiftKey", // shift key adds to selection
                        box: true

    });
    map_map.addControl(select);
    select.box=false;
    select.activate();


    //callback for moveend event 
    map_map.events.register("zoomend", map_map, check_zoomend);
    map_map.events.register("moveend", map_map, check_moveend);

    vectorLayer = new OpenLayers.Layer.Vector("Current feature", {
                style: layer_style,
                renderers: renderer,
                projection: new OpenLayers.Projection("EPSG:2193".toUpperCase()),
                displayInLayerSwitcher:false
            });
    map_map.addLayer(vectorLayer);

    /* create click controllers*/
    add_click_to_select_all_controller();
    click_to_select_all = new OpenLayers.Control.Click();
    map_map.addControl(click_to_select_all);

    add_click_to_copy_link();
    click_to_copy_link = new OpenLayers.Control.Click();
    map_map.addControl(click_to_copy_link);

    add_click_to_copy_start_point();
    click_to_copy_start_point = new OpenLayers.Control.Click();
    map_map.addControl(click_to_copy_start_point);

    add_click_to_copy_end_point();
    click_to_copy_end_point = new OpenLayers.Control.Click();
    map_map.addControl(click_to_copy_end_point);

    add_click_to_create_controller();
    click_to_create = new OpenLayers.Control.Click();
    map_map.addControl(click_to_create);

    select_catchment=new OpenLayers.Control.SelectFeature(catchments_layer);
    map_map.addControl(select_catchment);
    add_draw_controller();

    /* by default, activate only xclick_to_select */
    click_to_select_all.activate();
    map_enable_info();

    //map_map.zoomToExtent( mapBounds.transform(map_map.displayProjection, map_map.projection ) );

    if(typeof(defzoom)!="undefined" &&  defzoom!=null)  {
        map_map.zoomTo(defzoom-5);
    }
    if(typeof(def_x)!="undefined" &&  def_x!=null && typeof(def_y)!="undefined" &&  def_y!=null)  {
      document.selectform.currentx.value=def_x;
      document.selectform.currenty.value=def_y;
      map_centre();
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
                    styleMap: pt_styleMap,
                    displayInLayerSwitcher:false
                });



   /* copy selected feature to div */
    places_layer.events.on({
        'featureselected': function(feature) {
	     var f = places_layer.selectedFeatures.pop();
             select.unselectAll();
	     places_layer.selectedFeatures.push(f);
             document.selectform.select.value = f.attributes.id;
             document.selectform.selectname.value = f.attributes.name;
             document.selectform.selectx.value = f.geometry.x;
             document.selectform.selecty.value = f.geometry.y;
             document.selectform.selecttype.value = "/places/";
             if (!select.hover) simulate_click();

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

function catchments_layer_add() {

    catchments_layer = new OpenLayers.Layer.Vector("catchments", {
                    strategies: [new OpenLayers.Strategy.BBOX()],
                    protocol: new OpenLayers.Protocol.WFS({
                        url:  "http://routeguides.co.nz/cgi-bin/mapserv?map=/ms4w/apps/matts_app/htdocs/catchments.map",
                        featureType: "catchments",
                        extractAttributes: true
                    }),
                    styleMap: ca_styleMap,
                    displayInLayerSwitcher:false
                });

}

function routes_simple_layer_add() {

    routes_simple_layer = new OpenLayers.Layer.Vector("routes-simple", {
                    strategies: [new OpenLayers.Strategy.BBOX()],
                    protocol: new OpenLayers.Protocol.WFS({
                        url:  "http://routeguides.co.nz/cgi-bin/mapserv?map=/ms4w/apps/matts_app/htdocs/routes-simple.map",
                        featureType: "routes-simple",
                        extractAttributes: true
                    }),
                    styleMap: rt_styleMap,
                    displayInLayerSwitcher:false
                });
}

function docland_layer_add() {
    docland_layer = new OpenLayers.Layer.Vector("DOC Land", {
                    strategies: [new OpenLayers.Strategy.BBOX()],
                    protocol: new OpenLayers.Protocol.WFS({
                        url:  "http://routeguides.co.nz/cgi-bin/mapserv?map=/ms4w/apps/matts_app/htdocs/docland.map",
                        featureType: "docland"
                    }),
                    styleMap: pcl_styleMap,
                    displayInLayerSwitcher:false
                });


}
function docland_simple_layer_add() {
    docland_simple_layer = new OpenLayers.Layer.Vector("DOC Land", {
                    strategies: [new OpenLayers.Strategy.BBOX()],
                    protocol: new OpenLayers.Protocol.WFS({
                        url:  "http://routeguides.co.nz/cgi-bin/mapserv?map=/ms4w/apps/matts_app/htdocs/docland500.map",
                        featureType: "docland500"
                    }),
                    styleMap: pcl_styleMap,
                    displayInLayerSwitcher:false
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
                    styleMap: rt_styleMap,
                    displayInLayerSwitcher:false
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
             if (select.box) simulate_click();
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
    if(typeof(click_to_copy_link)!='undefined') click_to_copy_link.deactivate();
    if(typeof(click_to_create)!='undefined') click_to_create.deactivate();
    if(typeof(click_to_copy_start_point)!='undefined') click_to_copy_start_point.deactivate();
    if(typeof(click_to_copy_end_point)!='undefined') click_to_copy_end_point.deactivate();
    if(typeof(draw)!='undefined') draw.deactivate();
    map_disable_all();
}

function simulate_click() {
    if(typeof(click_to_select_all)!='undefined') if (click_to_select_all.active)click_to_select_all.trigger();
    if(typeof(click_to_copy_link)!='undefined') if (click_to_copy_link.active) click_to_copy_link.trigger();
    if(typeof(click_to_create)!='undefined') if (click_to_create.active) click_to_create.trigger();
    if(typeof(click_to_copy_start_point)!='undefined') if (click_to_copy_start_point.active) click_to_copy_start_point.trigger();
    if(typeof(click_to_copy_end_point)!='undefined') if(click_to_copy_end_point.active) click_to_copy_end_point.trigger();
}


function activate_draw() {
   vectorLayer.destroyFeatures;
   deactivate_all_click();
   draw.activate();
   map_enable_draw_line();
}

function activate_select_all() {

   deactivate_all_click();
   click_to_select_all.activate();
   map_enable_info();
}


function add_click_to_select_all_controller() {
  OpenLayers.Control.Click = OpenLayers.Class(OpenLayers.Control, {
     defaultHandlerOptions: {
         'single': true,
         'double': true,
         'pixelTolerance': 5,
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
          timeout: 20000,
          url: document.selectform.selecttype.value+document.selectform.select.value,
          complete: function() {
              /* complete also fires when error ocurred, so only clear if no error has been shown */
              if(map_size==2) map_smaller();
              document.getElementById("page_status").innerHTML = '';
          }
  
        });
        document.selectform.selecttype.value="";
        document.selectform.select.value="";
      }
    }
  });
 }



 function reset_map_controllers() {

    if(typeof(map_map)!='undefined') {

      /* disable click */
      deactivate_all_click();
      click_to_select_all.activate();
      map_enable_info();

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

function add_click_to_copy_link() {

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
        if (document.selectform.selecttype.value == '/routes/')  {
           document.getElementById("itemName").value=document.selectform.selectname.value;
           document.getElementById("itemId").value=document.selectform.select.value;
           document.getElementById("itemType").value='route';
        }

        if (document.selectform.selecttype.value == '/places/')  {
           document.getElementById("itemName").value=document.selectform.selectname.value;
           document.getElementById("itemId").value=document.selectform.select.value;
           document.getElementById("itemType").value='place';
        }
        if (document.selectform.selecttype.value == '/photos/')  {
           document.getElementById("itemName").value=document.selectform.selectname.value;
           document.getElementById("itemId").value=document.selectform.select.value;
           document.getElementById("itemType").value='photo';
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
       var locProj =  new OpenLayers.Projection("EPSG:4326");
       var thisPoint = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat).transform(mapProj,dstProj);
       /* convert to WGS84 and writ to location */
       var locPoint = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat).transform(mapProj,locProj);

       if ( typeof(document.placeform)!='undefined') {
       document.placeform.place_x.value=thisPoint.x;
       document.placeform.place_y.value=thisPoint.y;
       document.placeform.place_projection_id.value=dstProj.projCode.substr(5);
       document.placeform.place_location.value=locPoint.x+" "+locPoint.y;
       }

       if ( typeof(document.photoform)!='undefined') {
       document.photoform.photo_x.value=thisPoint.x;
       document.photoform.photo_y.value=thisPoint.y;
       document.photoform.photo_projection_id.value=dstProj.projCode.substr(5);
       document.photoform.photo_location.value=locPoint.x+" "+locPoint.y;
       }


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
  draw.events.register('featureadded', draw, route_endSelectLocation); 
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
  var mapProj =  new OpenLayers.Projection("EPSG:2193");

  if(plloc!="") {

    /* read location from form */
    feaWGS = new OpenLayers.Format.WKT().read(plloc);

    /*convert to map projectiob */
    geomMap = feaWGS.geometry.transform(srcProj, mapProj);
    pointFeature = new OpenLayers.Feature.Vector(geomMap,null,star_purple);

    /*add to map */
    vectorLayer.addFeatures(pointFeature);

    if (typeof(document.selectform)!='undefined') {

      document.selectform.currentx.value=feaWGS.geometry.x;
      document.selectform.currenty.value=feaWGS.geometry.y;
      if (map_pinned==false) map_centre();
    }
  }

}

function catchment_init(catchment_id) {

//  if (typeof(map_map)=='undefined') init();
  catchments_layer.setVisibility(true);
  select_catchment.activate();
  select_catchment.unselectAll();
  select_catchment.select(catchments_layer.features[catchment_id-1]);
}

function route_init(startloc, endloc, rtline, keep) {
  if (typeof(map_map)=='undefined') init();

  if ((keep==0) && (typeof(vectorLayer)!='undefined')) vectorLayer.destroyFeatures();

  var srcProj =  new OpenLayers.Projection("EPSG:4326");
  var mapProj =  new OpenLayers.Projection("EPSG:2193");
  /* add start point */

  if(startloc!="") {
    /* read location from form */
    var feaWGSs = new OpenLayers.Format.WKT().read(startloc);

    /*convert to map projectiob */
    var geomMap = feaWGSs.geometry.transform(srcProj, mapProj); 
    var pointFeature = new OpenLayers.Feature.Vector(geomMap,null,star_green);

    /*add to map */
    vectorLayer.addFeatures(pointFeature);
  }
  /* add end point */
  if(endloc!="") {
  
    /* read location from form */
    feaWGSe = new OpenLayers.Format.WKT().read(endloc);
  
    /*convert to map projectiob */
    geomMap = feaWGSe.geometry.transform(srcProj, mapProj);
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

  if (typeof(document.selectform)!='undefined' && endloc!="" && startloc!="") {
    document.selectform.currentx.value=(feaWGSs.geometry.x+feaWGSe.geometry.x)/2;
    document.selectform.currenty.value=(feaWGSs.geometry.y+feaWGSe.geometry.y)/2;
    if (map_pinned==false) map_centre();
  }

}

function place_selectPlace() {
  place_selectNothing();
  document.getElementById("placeplus").style.display="none";
  document.getElementById("placetick").style.display="block";

  vectorLayer.destroyFeatures();
  deactivate_all_click();
  click_to_create.activate();
  map_enable_draw_point();
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
  map_enable_select_point();
}


function route_selectEndPlace() { 
  route_selectNothing();
  document.getElementById("endplaceplus").style.display="none";
  document.getElementById("endplacetick").style.display="block";
   

  deactivate_all_click();
  click_to_copy_end_point.activate();
  map_enable_select_point();

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
    document.routeform.datasource.value="Drawn on map";
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
function link_select_on() {
  document.getElementById("link-select-on").style.display="none";
  document.getElementById("link-select-off").style.display="block";
  //document.selectform.select.value='';
  //document.selectform.selectname.value='';

  deactivate_all_click();
  click_to_copy_link.activate();
  map_enable_select_point();
}

function link_select_off() {
  document.getElementById("link-select-on").style.display="block";
  document.getElementById("link-select-off").style.display="none";
  
  deactivate_all_click();
}


// MISCELANEOUS PAGE EVENT HANDLING THAT HAVE NOTHING TO DO WITH THE MAP

function signinHandler() {
  var pos=map_map.getCenter();

  document.getElementById("signin_x").value=pos.lon;
  document.getElementById("signin_y").value=pos.lat;
  document.getElementById("signin_zoom").value=map_map.getZoom()+5;
}

function linkHandler(entity_name) {
    /* close the dropdown */
    $('.dropdown').removeClass('open');

    /* show 'loading ...' */
    document.getElementById("page_status").innerHTML = 'Loading ...'
    $(function() {
     $.rails.ajax = function (options) {
       options.tryCount= (!options.tryCount) ? 0 : options.tryCount;0;
       options.timeout = 15000*(options.tryCount+1);
       options.retryLimit=3;
       options.complete = function(jqXHR, thrownError) {
         /* complete also fires when error ocurred, so only clear if no error has been shown */
         if(thrownError=="timeout") {
           this.tryCount++;
           document.getElementById("page_status").innerHTML = 'Retrying ...';
           this.timeout=15000*this.tryCount;
           if(this.tryCount<=this.retryLimit) {
             $.rails.ajax(this);
           } else {
             document.getElementById("page_status").innerHTML = 'Timeout';
           }
         }
         if(thrownError=="error") {
           if(jqXHR.status=="409") {
             document.getElementById("page_status").innerHTML = 'Item exists (duplicate save)';
             alert("Error 409: Your item has been saved (we've checked), but the original response from the server was lost.  You can safely navigate away from this page using the menus at the top of the screen.  Use Add -> Route if you wish to continue adding route segments.");
           } else {
             document.getElementById("page_status").innerHTML = 'Error: '+jqXHR.status;
           }

         } 
         if(thrownError=="success") {
           document.getElementById("page_status").innerHTML = '';
           if(map_size==2) map_smaller();
         }
         lastUrl=document.URL;
       }

       return $.ajax(options);
     };
   }); 

   
 
}

function linkWithExtent(entity_name) {
    /* get x,y of place, transform to WGS and write to form */
    var mapProj =  map_map.projection;
    var dstProj =  new OpenLayers.Projection("EPSG:4326");
    
    var currentextent=map_map.getExtent().transform(mapProj, dstProj);
    document.findform.extent_left.value=currentextent.left;
    document.findform.extent_right.value=currentextent.right;
    document.findform.extent_top.value=currentextent.top;
    document.findform.extent_bottom.value=currentextent.bottom;
  
    linkHandler(entity_name);
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

   function clickswitch(divname) {
     if (document.getElementById('fw_r'+divname).style.display == 'block') {
       document.getElementById('fw_r'+divname).style.display = 'none';
       document.getElementById('rv_r'+divname).style.display = 'block';
       document.getElementById('fw_t'+divname).style.display = 'none';
       document.getElementById('rv_t'+divname).style.display = 'block';
     } else {
       document.getElementById('fw_r'+divname).style.display = 'block';
       document.getElementById('rv_r'+divname).style.display = 'none';
       document.getElementById('fw_t'+divname).style.display = 'block';
       document.getElementById('rv_t'+divname).style.display = 'none';
     }
   }

   function updatePlace(buttonName) {
     placesStale=true;
     linkHandler(buttonName);
   }

   function updateRoute(buttonName) {
     //Validation
     if(document.getElementById("locationtick").style.display=="block") {
       alert("You must confirm the route you have drawn before you can save. Click the green tick next to Route Points");
       //cancel
       return false;
     } else {
     if(document.routeform.route_location.value.length<1 && document.getElementById("route_published").checked==true) {
       alert("All routes must have a set of route points on the map. Please either draw / upload a set of route points, or uncheck the 'published' checkbox to save as draft");
     return false;
     } else { 
     if(document.routeform.route_experienced_at.value.length<1 && document.getElementById("route_published").checked==true) {
       rtnval=confirm("Date experienced is blank.  If you save the route will be greyed-out and marked as 'not experienced'. Did you really mean to save a route you haven't experienced?");
       return rtnval;
     } } }
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
     document.title = 'Route Guides'+title;
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
         document.routeform.datasource.value="Uploaded from GPS";
       } else {
         alert("Invald GPX file");
       }
       
     }
}


   function copyGpx() {
     
     GPXtoWKT();
     // redraw map
     route_init(document.routeform.route_startplace_location.value,
              document.routeform.route_endplace_location.value,
              document.routeform.route_location.value, 0);

}

function overlay_getLinzTileURL(bounds,url) {
    var res = this.map.getResolution();
    var x = Math.round((bounds.left - this.tileOrigin.lon) / (res * this.tileSize.w));
    var y = -Math.round((bounds.top - this.tileOrigin.lat) / (res * this.tileSize.h));
    var z = this.map.getZoom();
    //if (mapBounds.intersectsBounds( bounds ) && z >= mapMinZoom && z <= mapMaxZoom ) {
       //console.log( this.url + z + "/" + x + "/" + y + "." + this.type);
        return this.url + z + "/" + x + "/" + y + "." + this.type;
    //} else {
     //   return "http://www.maptiler.org/img/none.png";
   // }

}
function overlay_getTileURL(bounds,url) {
    var res = this.map.getResolution();
    var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
    var y = Math.round((bounds.bottom - this.tileOrigin.lat ) / (res * this.tileSize.h));
    var z = this.map.getZoom()+5;
    if (mapBounds.intersectsBounds( bounds ) && z >= mapMinZoom+5 && z <= mapMaxZoom+5 ) {
       //console.log( this.url + z + "/" + x + "/" + y + "." + this.type);
        return this.url + z + "/" + x + "/" + y + "." + this.type;
    } else {
        return "http://www.maptiler.org/img/none.png";
    }

}


function map_disable_all() {

  if (typeof(info_button)!='undefined') {
    info_button.panel_div.style.display="none";
    select_point_button.panel_div.style.display="none";
    select_line_button.panel_div.style.display="none";
    draw_point_button.panel_div.style.display="none";
    draw_line_button.panel_div.style.display="none";
    disabled_button.panel_div.style.display="inline";
  }
}

function map_enable_info() {
  map_disable_all();
  info_button.panel_div.style.display="inline";
  disabled_button.panel_div.style.display="none";
}
function map_enable_select_point() {
  map_disable_all();
  select_point_button.panel_div.style.display="inline";
  disabled_button.panel_div.style.display="none";
}
function map_enable_select_line() {
  map_disable_all();
  select_line_button.panel_div.style.display="inline";
  disabled_button.panel_div.style.display="none";
}
function map_enable_draw_point() {
  map_disable_all();
  draw_point_button.panel_div.style.display="inline";
  disabled_button.panel_div.style.display="none";
}
function map_enable_draw_line() {
  map_disable_all();
  draw_line_button.panel_div.style.display="inline";
  disabled_button.panel_div.style.display="none";
}

function map_show_default() {

    document.getElementById("show_route").style.border="2px solid lightgreen"; 
    show_route=true;
    document.getElementById("show_accomodation").style.border="2px solid lightgreen"; 
    show_accomodation=true;
    document.getElementById("show_roadend").style.border="2px solid lightgreen"; 
    show_roadend=true;
    document.getElementById("show_summit").style.border="2px solid lightgreen"; 
    show_summit=true;
    document.getElementById("show_scenic").style.border="2px solid lightgreen"; 
    show_scenic=true;
    document.getElementById("show_crossing").style.border="2px solid lightgreen"; 
    show_crossing=true
    document.getElementById("show_other").style.border="2px solid lightgreen"; 
    show_other=true;
    document.getElementById("show_docland").style.border="2px solid orange"; 
    show_docland=false;
}

function map_show_grey() {

  if (show_route) { document.getElementById("show_route").style.border="2px solid lightgreen"};
  if (show_accomodation) { document.getElementById("show_accomodation").style.border="2px solid lightgrey"};
  if (show_roadend) { document.getElementById("show_roadend").style.border="2px solid lightgrey"};
  if (show_summit) { document.getElementById("show_summit").style.border="2px solid lightgrey"};
  if (show_scenic) { document.getElementById("show_scenic").style.border="2px solid lightgrey"};
  if (show_crossing) { document.getElementById("show_crossing").style.border="2px solid lightgrey"};
  if (show_other) { document.getElementById("show_other").style.border="2px solid lightgrey"};
  if (show_docland) { document.getElementById("show_docland").style.border="2px solid lightgreen"};

}

function map_show_green() {

  if (show_route) { document.getElementById("show_route").style.border="2px solid lightgreen"};
  if (show_accomodation) { document.getElementById("show_accomodation").style.border="2px solid lightgreen"};
  if (show_roadend) { document.getElementById("show_roadend").style.border="2px solid lightgreen"};
  if (show_summit) { document.getElementById("show_summit").style.border="2px solid lightgreen"};
  if (show_scenic) { document.getElementById("show_scenic").style.border="2px solid lightgreen"};
  if (show_crossing) { document.getElementById("show_crossing").style.border="2px solid lightgreen"};
  if (show_other) { document.getElementById("show_other").style.border="2px solid lightgreen"};
  if (show_docland) { document.getElementById("show_docland").style.border="2px solid lightgreen"};
}

function toggle_docland() {
  if (show_docland) {
    document.getElementById("show_docland").style.border="2px solid orange";
    docland_layer.setVisibility(false);
    docland_simple_layer.setVisibility(false);
  } else {
    document.getElementById("show_docland").style.border="2px solid lightgreen";
  };

  var dialog_filter=document.getElementById("dialog_filter");
  var main_filter=document.getElementById("filterdiv");
  dialog_filter.innerHTML=main_filter.innerHTML;

  show_docland=!show_docland;
  check_zoomend();
  //routes_layer.refresh({force:true});
}
function toggle_routes() {
  if (show_route) {
    document.getElementById("show_route").style.border="2px solid orange";
    routes_layer.setVisibility(false);
    routes_simple_layer.setVisibility(false);
  } else {
    document.getElementById("show_route").style.border="2px solid lightgreen";
  };
  //update dialog too
  var dialog_filter=document.getElementById("dialog_filter");
  var main_filter=document.getElementById("filterdiv");
  dialog_filter.innerHTML=main_filter.innerHTML;

  show_route=!show_route;
  check_zoomend();
  //routes_layer.refresh({force:true});
}
function apply_filter(category,newstate){
  var visibility=0;
  if (newstate) visibility=1;
  for (index=0; index<pt_styleMap.styles['default'].rules.length; ++index) {
     if (pt_styleMap.styles['default'].rules[index].filter != null)  {
       if ( pt_styleMap.styles['default'].rules[index].symbolizer.category == category ) {
         pt_styleMap.styles['default'].rules[index].symbolizer.strokeOpacity=visibility;
         pt_styleMap.styles['default'].rules[index].symbolizer.fillOpacity=visibility;
       };
     };
  };
}

function apply_current_filters() {
  apply_filter("accomodation",show_accomodation);
  apply_filter("roadend",show_roadend);
  apply_filter("summit",show_summit);
  apply_filter("scenic",show_scenic);
  apply_filter("crossing",show_crossing);
  apply_filter("other",show_other);
}

function toggle_map(category){
  currentState=eval("show_"+category);
  if (currentState) {
    document.getElementById("show_"+category).style.border="2px solid orange";
  } else {
    document.getElementById("show_"+category).style.border="2px solid lightgreen";
  };

  //update dialog too
  var dialog_filter=document.getElementById("dialog_filter");
  var main_filter=document.getElementById("filterdiv");
  dialog_filter.innerHTML=main_filter.innerHTML;
 
  apply_filter(category, !currentState);
  places_layer.refresh({force:true});
  
  switch (category) {
   case "accomodation":
     show_accomodation=!currentState;
     break;
   case "roadend":
     show_roadend=!currentState;
     break;
   case "summit":
     show_summit=!currentState;
     break;
   case "scenic":
     show_scenic=!currentState;
     break;
   case "crossing":
     show_crossing=!currentState;
     break;
   case "other":
     show_other=!currentState;
     break;
  }  
  check_zoomend();

}
function check_moveend() {   
     if (places_layer.visible && places_layer.features.length==0) places_layer.refresh({force:true});
     if (routes_layer.visible && routes_layer.features.length==0) routes_layer.refresh({force:true});
     if (routes_simple_layer.visible && routes_simple_layer.features.length==0) routes_simple_layer.refresh({force:true});
}

function check_zoomend() {
       var x = map_map.getZoom();
       if(x>mapMaxZoom) setTimeout( function() { map_map.zoomTo(mapMaxZoom);}, 100);
       if(x<mapMinZoom) setTimeout( function() { map_map.zoomTo(mapMinZoom);}, 100);

        // hide places above 7 zoom (too much data).  Turn back on if we drop below 
        if( x < 4) {
            places_layer.setVisibility(false);
            if (show_route) {
              routes_layer.setVisibility(false);
              routes_simple_layer.setVisibility(true);
            }
            map_show_grey();
       } else {
                places_layer.setVisibility(true);
                if(show_route) {
                  routes_layer.setVisibility(true);
                  routes_simple_layer.setVisibility(false);
                }
                map_show_green();
       }
       if (x < 6) {
            if (show_docland) {
              docland_layer.setVisibility(false);
              docland_simple_layer.setVisibility(true);
            }
       } else {
                if(show_docland) {
                  docland_layer.setVisibility(true);
                  docland_simple_layer.setVisibility(false);
                }
       }
    }

    function HelpWindow(path) {
       var mywindow = window.open(path+'/?help=true', 'Help', 'height=1024,width=768' );
        mywindow.focus(); 
    }

    function PrintElem(elem)
    {
        Popup(document.getElementById(elem).innerHTML, document.getElementById(elem).offsetHeight,document.getElementById(elem).offsetWidth);
    }

    function Popup(data, h, w) 
    {
        var mywindow = window.open('', 'routeguides.co.nz', 'height='+h+',width='+w);
        mywindow.document.write('<html><head><title>routeguides.co.nz</title>');
        mywindow.document.write('<link rel="stylesheet" type="text/css" href="/assets/print.css" /> ');
        mywindow.document.write('</head><body >');
        mywindow.document.write(data);
        mywindow.document.write('</body></html>');

        mywindow.focus(); 
        if (navigator.userAgent.toLowerCase().indexOf("chrome") < 0) {
//          mywindow.print(); 
        }
     
        mywindow.focus(); 
        return true;
    }

    function link_search_on() 
    {
       document.getElementById("link-find").style.display="block";
       document.getElementById("searchon").style.display="none";
       document.getElementById("searchoff").style.display="block";


    }

    function link_search_off()
    {
       document.getElementById("link-find").style.display="none";
       document.getElementById("searchon").style.display="block";
       document.getElementById("searchoff").style.display="none";

    }

    function link_hyper_on()
    {
       $("#itemName").prop('readonly',false);
       document.getElementById("itemType").value='URL';
       document.getElementById("hyperlinkon").style.display="none";
       document.getElementById("hyperlinkoff").style.display="block";


    }

    function link_hyper_off()
    {
       $("#itemName").prop('readonly',true);
       document.getElementById("itemType").value='';
       document.getElementById("itemName").value='';
       document.getElementById("link-find").style.display="none";
       document.getElementById("hyperlinkon").style.display="block";
       document.getElementById("hyperlinkoff").style.display="none";

    }

    function link_confirm(type,id, name)
    {
      document.getElementById("link-find").style.display="none";
      document.getElementById("searchon").style.display="block";
      document.getElementById("searchoff").style.display="none";
      document.getElementById("itemType").value=type ;
      document.getElementById("itemId").value=id ;
      document.getElementById("itemName").value=name ;
    }

    function editcommenton()
    {
      document.getElementById("comment_form").style.display="block";
      document.getElementById("addComment").style.display="none";
    }

    function editcommentoff()
    {
      document.getElementById("comment_form").style.display="none";
      document.getElementById("addComment").style.display="block";
    
    }

    function map_centre()
    {
      if(document.selectform.currentx.value>0) {
        map_map.setCenter([document.selectform.currentx.value,document.selectform.currenty.value]);
      } else {
          map_map.zoomToExtent(mapBounds);
      }
    }

    function pin_map()
    {
      if (map_pinned==true)
      {
           map_pinned=false;
           pin_button.panel_div.style.border="";
//           document.getElementById("pin-map").style.border="2px solid orange";
           map_centre(); 
      } else {
           map_pinned=true;
           pin_button.panel_div.style.border="2px solid lightgreen";
//           document.getElementById("pin-map").style.border="2px solid lightgreen";
      }
    }


  function select_box() {

    select.box=!select.box;
    select.hover=!select.box;
    if(select.active) {
       select.deactivate();
       select.activate();
    }
    toggle_select();
    if(select.box==true) {
           pan_button.panel_div.style.display="inline";
           box_button.panel_div.style.display="none";

    } else {
           pan_button.panel_div.style.display="none";
           box_button.panel_div.style.display="inline";
    }
  }
 
  function toggle_select() {
    // Restart current click controller
    if(typeof(click_to_select_all)!='undefined') if (click_to_select_all.active) { 
     click_to_select_all.deactivate();
     click_to_select_all.activate();
    }
    if(typeof(click_to_copy_link)!='undefined') if (click_to_copy_link.active) {
      click_to_copy_link.deactivate();
      click_to_copy_link.activate();
    }
    if(typeof(click_to_create)!='undefined') if (click_to_create.active)  {
       click_to_create.deactivate();
       click_to_create.activate();
    }
    if(typeof(click_to_copy_start_point)!='undefined') if (click_to_copy_start_point.active) {
      click_to_copy_start_point.deactivate();
      click_to_copy_start_point.activate();
    }
    if(typeof(click_to_copy_end_point)!='undefined') if(click_to_copy_end_point.active) {
      click_to_copy_end_point.deactivate();
      click_to_copy_end_point.activate();
    }
  }

function loadLink(linkurl) {
   document.getElementById("page_status").innerHTML = 'Loading ...';
   var tryCount=0;
   $.ajax({
          beforeSend: function (xhr){
            xhr.setRequestHeader("Content-Type","application/javascript");
            xhr.setRequestHeader("Accept","text/javascript");
          },
          type: "GET",
          url: linkurl,
          tryCount: (!tryCount) ? 0 : tryCount,
          timeout: 5000*(tryCount+1),
          retryLimit: 3,
          complete: function(jqXHR, thrownError) {
             /* complete also fires when error ocurred, so only clear if no error has been shown */
             if(thrownError=="timeout") {
               this.tryCount++;
               document.getElementById("page_status").innerHTML = 'Retrying ...';
               this.timeout=5000*this.tryCount;
               if(this.tryCount<=this.retryLimit) {
                 $.rails.ajax(this);
               } else {
                 document.getElementById("page_status").innerHTML = 'Timeout';
               }
             }
             if(thrownError=="error") {
                  document.getElementById("page_status").innerHTML = 'Error: '+jqXHR.status;
             }
             if(thrownError=="success") {
               if(map_size==2) map_smaller();
               document.getElementById("page_status").innerHTML = '';
             }
             lastUrl=document.URL;
          }
    });


}
function showVersion() {
  loadLink(location.protocol + '//' + location.host + location.pathname+"/?version="+document.getElementById("versions").value);
}

function show_div(div) {
   document.getElementById(div).style.display="block";
}

function mapKey() {
        BootstrapDialog.show({
            title: "Legend",
            message: $('<div id="info_details2">Retrieving ...</div>'),
            size: "size-small"
        });

        $.ajax({
          beforeSend: function (xhr){
            xhr.setRequestHeader("Content-Type","application/javascript");
            xhr.setRequestHeader("Accept","text/javascript");
          },
          type: "GET",
          timeout: 10000,
          url: "/legend?category="+route_class+"&projection="+current_proj,
          error: function() {
              document.getElementById("info_details2").innerHTML = 'Error contacting server';
          },
          complete: function() {
              document.getElementById("page_status").innerHTML = '';
          }
        });
}
function mapLayers() {
        BootstrapDialog.show({
            title: "Select basemap",
            message: $('<div id="info_details2">Retrieving ...</div>'),
            size: "size-small"
        });

        $.ajax({
          beforeSend: function (xhr){
            xhr.setRequestHeader("Content-Type","application/javascript");
            xhr.setRequestHeader("Accept","text/javascript");
          },
          type: "GET",
          timeout: 10000,
          url: "/layerswitcher?baselayer="+map_map.baseLayer.name,
          error: function() {
              document.getElementById("info_details2").innerHTML = 'Error contacting server';
          },
          complete: function() {
              document.getElementById("page_status").innerHTML = '';
          }

        });

}
function print_map() {
        BootstrapDialog.show({
            title: "Save / print map",
            message: $('<div id="info_details2">Retrieving ...</div>'),
            size: "size-small"
        });

        $.ajax({
          beforeSend: function (xhr){
            xhr.setRequestHeader("Content-Type","application/javascript");
            xhr.setRequestHeader("Accept","text/javascript");
          },
          type: "GET",
          timeout: 10000,
          url: "/print",
          error: function() {
              document.getElementById("info_details2").innerHTML = 'Error contacting server';
          },
          complete: function() {
              document.getElementById("page_status").innerHTML = '';
          }

        });

}
 function select_maplayer(name, url, basemap, minzoom, maxzoom) {
    $.each(BootstrapDialog.dialogs, function(id, dialog){
        dialog.close();
    });
      if(mapset=="mapspast" && basemap=="linz") {
        init_linz()
      }
      if(mapset=="linz" && basemap=="mapspast") {
        init_mapspast()
      }
      var thenewbase = map_map.getLayersByName(name)[0];
      map_map.setBaseLayer(thenewbase);
      map_map.baseLayer.setVisibility(true);
      mapMinZoom=minzoom;
      mapMaxZoom=maxzoom;
}


function mapFilter() {
        var filterDivContent = document.getElementById('filterdiv');
        BootstrapDialog.show({
            title: "Selected map filters",
            message: $("<div id='dialog_filter'>"+filterDivContent.innerHTML+"</div>"),
            size: "size-small"
        });
        
}
function printmap(filetype) {
  var xl=map_map.getExtent().left;
  var xr=map_map.getExtent().right;
  var yt=map_map.getExtent().top;
  var yb=map_map.getExtent().bottom;
  var width=document.printform.pix_width.value;
  var height=document.printform.pix_height.value;
  layerid=map_map.baseLayer.name;
//  sheetid=document.extentform.layerid.value;
  var maxzoom=mapMaxZoom;
  var filename=document.printform.filename.value;
  window.open('http://au.mapspast.org.nz/printrg.html?print=true&left='+xl+'&right='+xr+'&top='+yt+'&bottom='+yb+'&layerid='+layerid+'&wwidth='+width+'&wheight='+height+'&maxzoom='+maxzoom+'&filetype='+filetype+'&filename='+filename, 'printwindow');
  return false;
}

function updateDimensions() {
   var papersize=document.printform.size.value

   document.printform.pix_width.value=paperwidths[papersize];
   document.printform.pix_height.value=paperheights[papersize];
}

function updateProjection() {
            current_proj=document.getElementById("projections").value;
            current_projname=getSelectedText("projections");
            //WGS 4dp, otherwise 0
            if(current_proj=="4326") { current_projdp=4 } else { current_projdp=0 }; 
            $.each(BootstrapDialog.dialogs, function(id, dialog){
                dialog.close();
            });
            if (mapset=="mapspast") {
              init_mapspast();
            } else {
              init_linz();
            }
}

function updateRouteClass() {
   route_class=document.getElementById("routeclasses").value;
        $.ajax({
          beforeSend: function (xhr){
            xhr.setRequestHeader("Content-Type","application/javascript");
            xhr.setRequestHeader("Accept","text/javascript");
          },
          type: "GET",
          timeout: 10000,
          url: "/styles.js?category="+route_class,
          error: function() {
          },
          complete: function() {
            $.each(BootstrapDialog.dialogs, function(id, dialog){
                dialog.close();
            });
            if (mapset=="mapspast") {
              init_mapspast();
            } else {
              init_linz();
            }
          //  setTimeout( function() { mapKey();}, 300);
          }

        });
    
}

function getSelectedText(elementId) {
    var elt = document.getElementById(elementId);

    if (elt.selectedIndex == -1)
        return null;

    return elt.options[elt.selectedIndex].text;
}

function map_bigger() {
  document.getElementById('map_map').style.display="none";
  if (map_size==1) {
    $('#left_panel').toggleClass('span5 span12'); 
    $('#right_panel').toggleClass('span7 span0');
  setTimeout( function() {document.getElementById('right_panel').style.display="none";}, 100);
    map_size=2;
  }

  if (map_size==0) {
    $('#left_panel').toggleClass('span0 span5'); 
    $('#right_panel').toggleClass('span12 span7');
    document.getElementById('left_panel').style.display="block";
    map_size=1;
  }
  setTimeout( function() { 
    map_map.updateSize();
    document.getElementById('map_map').style.display="block";
    setTimeout( function() { map_map.updateSize(); }, 1000);
    map_map.updateSize();
  }, 200);
  return false ;
}

function map_smaller() {

  document.getElementById('map_map').style.display="none";
  if (map_size==1) {
    $('#left_panel').toggleClass('span5 span0'); 
    $('#right_panel').toggleClass('span7 span12');
    document.getElementById('left_panel').style.display="none";
    map_size=0;
  }
  if (map_size==2) {
    document.getElementById('right_panel').style.display="block";
    $('#left_panel').toggleClass('span12 span5'); 
    $('#right_panel').toggleClass('span0 span7');
    map_size=1;
  }

  setTimeout( function() { 
    map_map.updateSize();
    document.getElementById('map_map').style.display="block";
    setTimeout( function() { map_map.updateSize(); }, 1000);
    map_map.updateSize();
  }, 200);

  return false ;
}
