LINZ_API_KEY='d01gerrwytrsmhgce8xp5sjrrmb'
var clickMode;
var searchMode;
var site_map_size=1;
var site_selected_layer;
var places_layer;
var myplaces_layer;
var routes_layer;
var myroutes_layer;
var routes_simple_layer;
var myroutes_simple_layer;
var parks_layer;
var parks_simple_layer;
var parks_very_simple_layer;
var site_show_parks=false;
var site_show_beenthere=false;
var site_route_classifier="routetype_id";
var site_rt_styles=[];
var site_pt_styles=[];
var site_map_pinned=false;
var site_routesStale=false;
var site_placesStale=false;
var site_myroutesStale=false;
var site_myplacesStale=false;
var site_current_userid;
var site_select_id_dest;
var site_select_name_dest;
var site_select_loc_dest;
var site_select_x_dest;
var site_select_y_dest;
var site_current_style=null;
var site_signed_in=false;   // an indicator for display - not for security
var print=false;
var print_raster_ready=false;
var print_routes_ready=false;
var print_places_ready=false;
var print_layer;
var routesListenerKey;
var placesListenerKey;
var rasterListenerKey;
var rasterLoadListenerKey;
var rasterLoadListenerKey;
var raster_load_count=0;
var raster_loaded_count=0;

//styles
var site_blue_dot;
var site_pink_dot;
var site_purple_star;
var site_red_star;
var site_green_star;
var site_red_line;
var site_docland_style;
var site_highlight_polygon;
var site_docland_styles=[];

//destinations for callbacks
var site_wktfield;
var site_fr=new FileReader();

var debug_f;
function site_init(user_id) {
  if(typeof(map_map)=='undefined') {
    site_init_styles();
    map_init_mapspast('map_map');
    site_create_default_rt_styles();
    site_create_pt_styles();
    site_add_vector_layers();
  
    if(!print) map_map.addLayer(map_scratch_layer);
    if(!print) map_add_tooltip();
    if(!print) map_on_click_activate(map_navigate_on_click_callback);
    if (!print && $(window).width() < 960) {
       setTimeout( function() {site_smaller_map()}, 300);
    }
    if(typeof(def_x)!='undefined' && typeof(def_y)!='undefined') {
       var centre='POINT('+def_x+' '+def_y+')';
       map_centre(centre,'EPSG:2193');
    }
    if(typeof(def_zoom)!='undefined') {
       map_zoom(def_zoom);
    }
  }
  
  if(typeof(user_id)!='undefined' && user_id>0)  {
    site_add_my_layers(user_id);
    site_signed_in=true;
  }
}

function print_init(user_id) {
  if (filetype=='prj') {
      var blob = new Blob(['PROJCS["NZGD_2000_New_Zealand_Transverse_Mercator",GEOGCS["GCS_NZGD_2000",DATUM["D_NZGD_2000",SPHEROID["GRS_1980",6378137.0,298.257222101]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["False_Easting",1600000.0],PARAMETER["False_Northing",10000000.0],PARAMETER["Central_Meridian",173.0],PARAMETER["Scale_Factor",0.9996],PARAMETER["Latitude_Of_Origin",0.0],UNIT["Meter",1.0]]'], {type: "text/plain"});
      saveAs(blob, filename+".prj");
      window.close();
      return false;
  }

  print=true;
  document.getElementById('map_map').setAttribute("style","width:"+wwidth+"px;height:"+wheight+"px");
  site_init(user_id); 
  // only our layer
  map_map.getLayers().forEach(function (layer) {
      if (layer.get('name') != undefined && layer.get('name') === print_layerid) {
        layer.setVisible(true);
        print_layer=layer;
      } else {
        if (layer.getType()=='TILE') {
          layer.setVisible(false);
        };
      };
    });

   map_set_default_extent([mleft, mtop, mright, mbottom]);
   map_zoom_to_default_extent();

  var print_source=print_layer;
  if(map_map.getView().getZoom()>=3) {
    var routes_source=routes_layer;
    var places_source=places_layer;
  } else {
    var routes_source=routes_simple_layer;
    var places_source=null;
  }

  map_map.once('postrender', function(event) {

    rasterLoadListenerKey = print_source.getSource().on('tileloadstart', function() {
      raster_load_count++;
    });
    rasterListenerKey = print_source.getSource().on('tileloadend', function() {
      raster_loaded_count++;
      if(raster_load_count==raster_loaded_count) print_raster_ready=true;
       if(print_routes_ready==true && print_places_ready==true && print_raster_ready==true) {
          print_png();
       }
    });
    rasterListenerKey2 = print_source.getSource().on('tileloaderror', function() {
      raster_loaded_count++;
      if(raster_load_count==raster_loaded_count) print_raster_ready=true;
       if(print_routes_ready==true && print_places_ready==true && print_raster_ready==true) {
          print_png();
       }
    });
    routesListenerKey = routes_source.on('change', function(e) {
      if (routes_source.getSourceState() == 'ready') {
        print_routes_ready=true;
        ol.Observable.unByKey(routesListenerKey);
        if(print_raster_ready==true && print_places_ready==true) {
            print_png();
         }
      }
    });
    placesListenerKey = places_source.on('change', function(e) {
      if (places_source.getSourceState() == 'ready') {
        print_places_ready=true;
        ol.Observable.unByKey(placesListenerKey);
        if(print_raster_ready==true && print_routes_ready==true) {
            print_png();
         }
      }
    });
  });
}

function print_png() {
  ol.Observable.unByKey(rasterLoadListenerKey);
  ol.Observable.unByKey(rasterListenerKey);
  ol.Observable.unByKey(placesListenerKey);
  ol.Observable.unByKey(routesListenerKey);
  document.getElementById("map_status").innerHTML="";
  if (filetype=="png") {
        html2canvas(document.getElementById("map_map"), {
          allowTaint: true, onrendered: function(canvas) {
            ourcanvas=canvas;
            document.body.appendChild(canvas);
            document.getElementById("map_map").style.display="none";
            canvas.toBlob(function(blob) {
              saveAs(blob, filename+".png");
            });
          }
        });
  }

  if (filetype=='pgw') {
      var xres=0+map_map.getView().getResolution();
      var yres=-xres;
      var xleft=map_map.getView().calculateExtent()[0];
      var ytop=map_map.getView().calculateExtent()[3];
      var blob = new Blob([""+xres+"\n0\n0\n"+yres+"\n"+xleft+"\n"+ytop+"\n"], {type: "text/plain"});
      saveAs(blob, filename+".pgw");
      window.close();
  }

}
function site_add_my_layers(user_id) {
  if(user_id!=site_current_userid) {
    map_map.removeLayer(myplaces_layer);
    map_map.removeLayer(myroutes_layer);
    map_map.removeLayer(myroutes_simple_layer);
    var filter="<PropertyIsEqualTo><PropertyName>user_id</PropertyName><Literal>"+user_id+"</Literal></PropertyIsEqualTo>"; 
    //var filter='user_id='+user_id
    myplaces_layer=map_add_vector_layer("My Places", "https://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "myplaces",site_pink_dot,false,1,32,filter);
    myroutes_layer=map_add_vector_layer("My Routes", "https://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "myroutes",site_red_line,false,8,32,filter);
    myroutes_simple_layer=map_add_vector_layer("My Routes Simple", "https://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "myroutes-simple",site_red_line,false,1,8,filter);
    map_map.addLayer(myplaces_layer);
    map_map.addLayer(myroutes_layer);
    map_map.addLayer(myroutes_simple_layer);
    site_current_userid=user_id;
  }
}

function site_docland_style_function(feature, resoluton) {
  if(feature.get('isdoc')=="t")  return site_docland_styles[1];
  return site_docland_styles[2];
}

function site_add_vector_layers() {
  places_layer=map_add_vector_layer("Places", "https://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "places",site_point_style_function,true,8,32);
  routes_layer=map_add_vector_layer("Routes", "https://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "routes",site_route_style_function,true,8,32);
  routes_simple_layer=map_add_vector_layer("Routes Simple", "https://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "routes-simple",site_route_style_function,true,1,8);
  parks_layer=map_add_vector_layer("Parks", "https://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "parks",site_docland_style_function,false,11,32);
  parks_simple_layer=map_add_vector_layer("Parks Simple", "https://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "parks_simple",site_docland_style_function,false,8,11);
  parks_very_simple_layer=map_add_vector_layer("Parks Very Simple", "https://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "parks_very_simple",site_docland_style_function,false,1,8);
  map_map.addLayer(places_layer);
  map_map.addLayer(routes_layer);
  map_map.addLayer(routes_simple_layer);
  map_map.addLayer(parks_layer);
  map_map.addLayer(parks_simple_layer);
  map_map.addLayer(parks_very_simple_layer);

}

function site_pinMap() {
  if(site_map_pinned==0) {
     site_map_pinned=1;
     document.getElementById("mapPin").style.backgroundColor="#008800"
  } else {
     site_map_pinned=0;
     document.getElementById("mapPin").style.backgroundColor="#ffffff"
  }
}

function site_centreMap() {
  map_centre(map_last_centre,'EPSG:4326');

}

function site_mapKey() {
        BootstrapDialog.show({
            title: "Map options",
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
          url: "/legend?projection="+map_current_proj+"&category="+site_route_classifier,
          error: function() {
              document.getElementById("info_details2").innerHTML = 'Error contacting server';
          },
          complete: function() {
//              document.getElementById("page_status").innerHTML = '';
          }
        });
}



function site_add_layers() {
        map_add_raster_layer('NZTM Topo 2019', 'https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_b1d1ad52024f4f1b909bfea0e41fbff8/mapspast/2193/topo50-2019/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
	//map_add_raster_layer('NZTM Topo 2019', 'http://au.mapspast.org.nz/topo50-2019/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
        map_add_raster_layer('Public Access Land', 'https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_b1d1ad52024f4f1b909bfea0e41fbff8/mapspast/2193/pal-2193/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
        //map_add_raster_layer('Public Access Land', 'http://au.mapspast.org.nz/pal-2193/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
        map_add_raster_layer('NZTM Topo 2009', 'https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_b1d1ad52024f4f1b909bfea0e41fbff8/mapspast/2193/topo50-2009/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
	//map_add_raster_layer('NZTM Topo 2009', 'http://au.mapspast.org.nz/topo50/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
        map_add_raster_layer('NZMS260 1999', 'https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_b1d1ad52024f4f1b909bfea0e41fbff8/mapspast/2193/nzms260-1999/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
	//map_add_raster_layer('NZMS260 1999', 'http://au.mapspast.org.nz/nzms260-1999/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
        map_add_raster_layer('NZMS1/260 1989', 'https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_b1d1ad52024f4f1b909bfea0e41fbff8/mapspast/2193/nzms-1989/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
	//map_add_raster_layer('NZMS1/260 1989','http://au.mapspast.org.nz/nzms-1989/{z}/{x}/{-y}.png','mapspast', 4891.969809375, 11);
        map_add_raster_layer('NZMS1 1979', 'https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_b1d1ad52024f4f1b909bfea0e41fbff8/mapspast/2193/nzms-1979/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
	//map_add_raster_layer('NZMS1 1979', 'http://au.mapspast.org.nz/nzms-1979/{z}/{x}/{-y}.png','mapspast', 4891.969809375, 11);
        map_add_raster_layer('NZMS1 1969', 'https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_b1d1ad52024f4f1b909bfea0e41fbff8/mapspast/2193/nzms-1969/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
        //map_add_raster_layer('NZMS1 1969','http://au.mapspast.org.nz/nzms-1969/{z}/{x}/{-y}.png','mapspast', 4891.969809375, 11);
        map_add_raster_layer('NZMS1 1959', 'https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_b1d1ad52024f4f1b909bfea0e41fbff8/mapspast/2193/nzms-1959/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
        //map_add_raster_layer('NZMS1 1959','http://au.mapspast.org.nz/nzms-1959/{z}/{x}/{-y}.png','mapspast',4891.969809375, 11);
        map_add_raster_layer('(LINZ) Topo50 latest','http://tiles-a.data-cdn.linz.govt.nz/services;key=d8c83efc690a4de4ab067eadb6ae95e4/tiles/v4/layer=767/EPSG:2193/{z}/{x}/{y}.png','linz',8690, 17);
        map_add_raster_layer('(LINZ) Airphoto latest','https://basemaps.linz.govt.nz/v1/tiles/aerial/2193/{z}/{x}/{y}.png?api='+LINZ_API_KEY,'linz',8690, 17);}

function site_add_controls() {
    if(!print) {
	map_create_control("/assets/key24.png","Show Legend / Configure map",site_mapKey,"mapKey");
	map_create_control("/assets/layers24.png","Select basemap",map_mapLayers,"mapLayers");
	map_create_control("/assets/walk24.png","Show places I've visited",site_toggle_beenthere,"mapBeenthere");
	map_create_control("/assets/doc24.png","Show parks",site_toggle_parks_layer,"mapParks");
	map_create_control("/assets/pin24.png","Pin map (do not automatically recentre)",site_pinMap,"mapPin");
	map_create_control("/assets/target24.png","Centre map on current item",site_centreMap,"mapCentre");
	map_create_control("/assets/save24.png","Save / print current map",print_map_dialog,"mapPrint");
  }
}

function site_bigger_map() {
  document.getElementById('map_map').style.display="none";
  if (site_map_size==1) {
    $('#left_panel').toggleClass('span5 span12');
    $('#right_panel').toggleClass('span7 span0');
    $('#actionbar').toggleClass('span7 span0');
  setTimeout( function() {document.getElementById('right_panel').style.display="none";}, 100);
    site_map_size=2;
  }

  if (site_map_size==0) {
    $('#left_panel').toggleClass('span0 span5');
    $('#right_panel').toggleClass('span12 span7');
    $('#actionbar').toggleClass('span12 span7');
    document.getElementById('left_panel').style.display="block";
    site_map_size=1;
  }
  setTimeout( function() {
    map_map.updateSize();
    document.getElementById('map_map').style.display="block";
    setTimeout( function() { map_map.updateSize(); }, 1000);
    map_map.updateSize();
    site_adjust_margins();
  }, 200);
  return false ;
}

function site_smaller_map() {
  document.getElementById('map_map').style.display="none";
  if (site_map_size==1) {
    $('#left_panel').toggleClass('span5 span0');
    $('#right_panel').toggleClass('span7 span12');
    $('#actionbar').toggleClass('span7 span12');
    document.getElementById('left_panel').style.display="none";
    site_map_size=0;
  }
  if (site_map_size==2) {
    document.getElementById('right_panel').style.display="block";
    $('#left_panel').toggleClass('span12 span5');
    $('#right_panel').toggleClass('span0 span7');
    $('#actionbar').toggleClass('span0 span7');
    site_map_size=1;
  }

  setTimeout( function() {
    map_map.updateSize();
    document.getElementById('map_map').style.display="block";
    setTimeout( function() { map_map.updateSize(); }, 1000);
    map_map.updateSize();
    site_adjust_margins();
  }, 200);

  return false ;

}

function site_signinHandler() {
  var pos=map_get_centre();
  var zoom=map_get_zoom();

  document.getElementById("signin_x").value=pos[0];
  document.getElementById("signin_y").value=pos[1];
  document.getElementById("signin_zoom").value=zoom+5;
}

function linkWithExtent(entity_name) {
    var currentextent=map_get_current_extent('EPSG:4326');
    document.findform.extent_left.value=currentextent[0]
    document.findform.extent_bottom.value=currentextent[1]
    document.findform.extent_right.value=currentextent[2]
    document.findform.extent_top.value=currentextent[3]

    linkHandler(entity_name);
}

function myplacesHandler(entity_name) {
  site_myplacesStale=true;
  site_myroutesStale=true;
  linkHandler(entity_name);
}
function linkHandler(entity_name) {
    /* close the dropdown */
    $('.dropdown').removeClass('open');

    /* show 'loading ...' */
    document.getElementById("page_status").innerHTML = 'Loading ...'

    $(function() {
     $.rails.ajax = function (options) {
       options.tryCount= (!options.tryCount) ? 0 : options.tryCount;0;
       options.timeout = 10000*(options.tryCount+1);
       options.retryLimit=1;
       options.complete = function(jqXHR, thrownError) {
         /* complete also fires when error ocurred, so only clear if no error has been shown */
         if(thrownError=="timeout") {
           this.tryCount++;
           document.getElementById("page_status").innerHTML = 'Retrying ...';
           this.timeout=30000*this.tryCount;
           if(this.tryCount<=this.retryLimit) {
             $.rails.ajax(this);
           } else {
             document.getElementById("page_status").innerHTML = 'Timeout';
           }
         }
         if(thrownError=="error") {
           document.getElementById("page_status").innerHTML = 'Error';
         }
         if(thrownError=="success") {
           if(site_map_size==2) site_smaller_map();
           document.getElementById("page_status").innerHTML = ''
         }
         lastUrl=document.URL;
       }
       return $.ajax(options);
     };
   });
}

   function update_title(title) {
     document.getElementById('logo').innerHTML='Routeguides '+title;
     document.title = 'NZ Route Guides'+title;
}
   function update_heading(title) {
     document.getElementById('logo').innerHTML='Routeguides '+title;
}



function print_map_dialog() {
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

function site_print_map(filetype) {
  var extent=map_map.getView().calculateExtent();
  var xl=extent[0];
  var xr=extent[2];
  var yt=extent[3];
  var yb=extent[1];
  var width=document.printform.pix_width.value;
  var height=document.printform.pix_height.value;
  layerid=map_current_layer;
  var maxzoom=15;
  var filename=document.printform.filename.value;
  window.open('https://au.mapspast.org.nz/printrg.html?print=true&left='+xl+'&right='+xr+'&top='+yt+'&bottom='+yb+'&layerid='+layerid+'&wwidth='+width+'&wheight='+height+'&maxzoom='+maxzoom+'&filetype='+filetype+'&filename='+filename, 'printwindow');
  return false;
}

function updateDimensions() {
   var papersize=document.printform.size.value

   document.printform.pix_width.value=paperwidths[papersize];
   document.printform.pix_height.value=paperheights[papersize];
}


function site_init_styles() {
  site_blue_dot=map_create_style("circle", 3, "#2222ff", "#22ffff", 1);
  site_pink_dot=map_create_style("circle", 4, "#ff00ff", "#22ffff", 1);
  site_purple_star=map_create_style("star", 10, "#8b008b", "#8b008b", 1);
  site_red_star=map_create_style("star", 10, "#990000","#990000", 1);
  site_green_star=map_create_style("star", 10, "#009900", "#009900", 1);
  site_red_line=map_create_style("", null, "#990000", "#990000", 4);
  site_docland_style=map_create_style("", null, 'rgba(0,128,0,0.4)', "#005500", 2);
  site_highlight_polygon=map_create_style("", null, 'rgba(128,0,0,0.6)', "#660000", 2);
  site_docland_styles[1]=map_create_style('',0, 'rgba(0,128,0,0.4)', "#005500", 2);
  site_docland_styles[2]=map_create_style('',0, 'rgba(128,255,128,0.4)', "#20a020", 1);

}

function site_updateRouteClass() {
   route_class=document.getElementById("routeclasses").value;
   current_classname=map_getSelectedValue("routeclasses");
   site_route_classifier=current_classname+"_id";
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
            map_refresh_layer(routes_layer);
            map_refresh_layer(routes_simple_layer);
          }
        });
}

function site_create_rt_style(id, colour) {
  site_rt_styles[id]=map_create_style('',0, colour, colour, 2);
}

function site_create_default_rt_styles() {
  site_rt_styles[1]=map_create_style('',0, '#666666', '#666666', 2);
  site_rt_styles[2]=map_create_style('',0, '#009900', '#009900', 2);
  site_rt_styles[3]=map_create_style('',0, '#006600', '#006600', 2);
  site_rt_styles[4]=map_create_style('',0, '#004433', '#004433', 2);
  site_rt_styles[5]=map_create_style('',0, '#000099', '#000099', 2);
  site_rt_styles[6]=map_create_style('',0, '#440044', '#440044', 2);
  site_rt_styles[7]=map_create_style('',0, '#440022', '#440022', 2);
  site_rt_styles[8]=map_create_style('',0, '#220011', '#220011', 2);
  site_rt_styles[9]=map_create_style('',0, '#000000', '#000000', 2);
  site_rt_styles[10]=map_create_style('',0, '#32e8f4', '#42e8f4', 2);
}

function site_create_pt_styles() {
  site_pt_styles={
     "Bridge": map_create_style('cross',5,'#414141','#414141',1),
     "Campsite": map_create_style('circle',4,'#00ffff','#00ffff',1),
     "Campspot": map_create_style('circle',4,'#00ff00','#00ff00',1),
     "Hut": map_create_style('circle',4,'#0000ff','#0000ff',1),
     "Junction": map_create_style('square',4,'#000000','#000000',1),
     "Locality": map_create_style('square',5,'#000000','#000000',1),
     "Lookout": map_create_style('circle',4,'#414141','#414141',1),
     "Other": map_create_style('square',5,'#00003d','#00003d',1),
     "Pass": map_create_style('triangle',5,'#880066','#880066',1),
     "River Crossing": map_create_style('x',5,'#414141','#414141',1),
     "Rock Biv": map_create_style('cross',5,'#414141','#414141',1),
     "Roadend": map_create_style('square',5,'#1a1a1a','#1a1a1a',1),
     "Summit": map_create_style('triangle',6,'#b26b00','#b26b00',1),
     "Waterbody": map_create_style('x',5,'#000099','#000099',1)
  };
}

function reset_map_controllers(user_id) {

//deactiavte all other click controllers

  if(typeof(map_map)=='undefined') site_init();

  if(user_id!=site_current_userid) site_add_my_layers(user_id);
  deactivate_all_click();
  map_clear_scratch_layer();
  map_map.updateSize();
  map_on_click_activate(map_navigate_on_click_callback);
  if(site_placesStale) {
     map_refresh_layer(places_layer);
     site_placesStale=false;
  }
  if(site_myplacesStale) {
     map_refresh_layer(myplaces_layer);
     site_myplacesStale=false;
  }
  if(site_routesStale) {
     map_refresh_layer(routes_layer);
     map_refresh_layer(routes_simple_layer);
     site_routesStale=false;
  }
  if(site_myroutesStale) {
     map_refresh_layer(myroutes_layer);
     map_refresh_layer(myroutes_simple_layer);
     site_myroutesStale=false;
  }
  site_hide_parks_layer();
  site_toggle_beenthere(site_show_beenthere);
  site_adjust_margins();
}

function site_adjust_margins() {
  var barht=$('#actionbar').height();
  var pc_element=document.getElementById('place_container');
  if(typeof(pc_element!="undefined") && pc_element!=null) {
    pc_element.style.marginTop=barht+"px";
  }
}

function deactivate_all_click() {

  if(typeof(map_map)!='undefined') map_on_click_deactivate(map_navigate_on_click_callback);
  if(typeof(map_map)!='undefined') map_on_click_deactivate(site_select_point_on_click_callback);
  if(typeof(map_map)!='undefined') map_on_click_deactivate(site_copy_link_callback);
  map_disable_draw();

  //set status icon to show blank
}

function site_point_style_function(feature, resoluton) {
  return site_pt_styles[feature.get('place_type')];
}

function site_route_style_function(feature, resoluton) {
  return site_rt_styles[feature.get(site_route_classifier)];
}


function site_navigate_to(url) {
  if(url.length>0) {
        document.getElementById("page_status").innerHTML = 'Loading ...';

        $.ajax({
          beforeSend: function (xhr){
            xhr.setRequestHeader("Content-Type","application/javascript");
            xhr.setRequestHeader("Accept","text/javascript");
          },
          type: "GET",
          timeout: 20000,
          url: '/'+url,
          complete: function() {
              /* complete also fires when error ocurred, so only clear if no error has been shown */
              if(site_map_size==2) site_smaller_map();
              document.getElementById("page_status").innerHTML = '';
          }

        });
      }
}

function route_init(startloc, endloc, rtline, keep) {
  if (typeof(map_map)=='undefined') site_init();
  if ((keep==0) && (typeof(map_scratch_layer)!='undefined')) map_clear_scratch_layer();
  /* add start point */
  if(startloc!="") {
    map_add_feature_from_wkt(startloc, 'EPSG:4326',site_green_star,true);
  }
  /* add end point */
  if(endloc!="") {
    map_add_feature_from_wkt(endloc, 'EPSG:4326',site_red_star,true);
  }


  /* add route */
  if(rtline!="") {
    map_add_feature_from_wkt(rtline, 'EPSG:4326',site_red_line,true);
  }
  
  if (site_map_pinned==false) map_centre(rtline,'EPSG:4326');

 // if (typeof(document.selectform)!='undefined' && endloc!="" && startloc!="") {
  //  document.selectform.currentx.value=(feaWGSs.geometry.x+feaWGSe.geometry.x)/2;
   // document.selectform.currenty.value=(feaWGSs.geometry.y+feaWGSe.geometry.y)/2;
  //}
  map_map.updateSize();
}


function place_init(plloc, keep) {
  if (typeof(map_map)=='undefined') site_init();

 if (keep==0) map_clear_scratch_layer();
  if(plloc && plloc.length>0) {
    map_add_feature_from_wkt(plloc, 'EPSG:4326',site_purple_star);
    if (site_map_pinned==false) map_centre(plloc,'EPSG:4326');
  }
  map_map.updateSize();
}
function park_init(plloc,keep) {
  if (typeof(map_map)=='undefined') site_init();

  if (keep==0) map_clear_scratch_layer();
  if(plloc && plloc.length>0) {
    cntloc=map_get_centre_of_geom(plloc);
    map_add_feature_from_wkt(cntloc, 'EPSG:4326',site_purple_star);
    map_add_feature_from_wkt(plloc, 'EPSG:4326',site_highlight_polygon);
    if (site_map_pinned==false) map_centre(plloc,'EPSG:4326');
  }
  map_map.updateSize();
}

function site_selectPlace(id_loc, name_loc, location_loc, disable_icon, enable_icon, style) {
  if(site_map_size==0) site_bigger_map();

  deactivate_all_click();
  document.getElementById(enable_icon).style.display="none";
  document.getElementById(disable_icon).style.display="block";

  map_on_click_activate(site_select_point_on_click_callback);
  
  site_select_id_dest=id_loc;
  site_select_name_dest=name_loc;
  site_select_loc_dest=location_loc;
  if(typeof(style)!='undefined' && style!=null) {
    site_current_style=style;
  } else {
    site_current_style=site_purple_star;
  }
}

function site_selectNothing(disable_icon, enable_icon) {
  document.getElementById(enable_icon).style.display="block";
  document.getElementById(disable_icon).style.display="none";
  deactivate_all_click();
  site_select_name_dest=null
  site_select_id_dest=null;
  site_current_style=null;
}

function site_copy_link_callback(evt) {
    var pixel = evt.pixel;
    var feature = map_map.forEachFeatureAtPixel(pixel, function(feature, layer) {
      if(layer!=map_scratch_layer) {
        return [feature, layer];
      } else {
        return null;
      }
    });
    if(feature) {
           document.getElementById("itemName").value=feature[0].get('name');
           document.getElementById("itemId").value=feature[0].get('id');
           document.getElementById("itemType").value=feature[1].get('name');
    }
}

function site_select_point_on_click_callback(evt) {
    var pixel = evt.pixel;
    var wktp = new ol.format.WKT;   //should be handled in map, not here
    var feature = map_map.forEachFeatureAtPixel(pixel, function(feature, layer) {
      if(layer==places_layer) { 
         return feature;
      } else {
         return null;
      }
    });
  
    if(feature) {
        //now copy it to where we want it 
      if(site_select_name_dest!=null)  document.getElementById(site_select_name_dest).value=feature.get('name');
      if(site_select_id_dest!=null)  document.getElementById(site_select_id_dest).value=feature.get('id');
      if(site_select_loc_dest!=null) document.getElementById(site_select_loc_dest).value=wktp.writeFeature(feature, { dataProjection: 'EPSG:4326', featureProjection: 'EPSG:2193'});
      if(site_select_x_dest!=null) document.getElementById(site_select_x_dest).value=feature.getGeometry().getCoordinates()[0];
      if(site_select_y_dest!=null) document.getElementById(site_select_y_dest).value=feature.getGeometry().getCoordinates()[1];
      debug_f=feature;
      //now mark it on map
      if(site_current_style!=null) {
           map_clear_scratch_layer(null, site_current_style);
           f2=feature.clone();
           f2.setStyle(site_current_style);
           map_add_feature(f2);
      }
    }
}

function site_drawPlace(disable_icon, enable_icon, place_loc, place_x, place_y) {
  if(site_map_size==0) site_bigger_map();
  deactivate_all_click();
  document.getElementById(enable_icon).style.display="none";
  document.getElementById(disable_icon).style.display="block";

  //map_clear_scratch_layer();
  map_enable_draw("Point",site_purple_star,place_loc, place_x ,place_y  ,true);
}

function site_drawRoute(disable_icon, enable_icon) {
  if(site_map_size==0) site_bigger_map();
  deactivate_all_click();
  document.getElementById(enable_icon).style.display="none";
  document.getElementById(disable_icon).style.display="block";

  //map_clear_scratch_layer();
  map_enable_draw("LineString",site_red_line,'route_location', null, null, true);
}

function site_updatePlace(button) {
  map_refresh_layer(places_layer);
  linkHandler(button);
}

function site_updateRoute(button) {
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

  map_refresh_layer(routes_layer);
  map_refresh_layer(routes_simple_layer);
  linkHandler(button);
}


   function clickplus(divname) {
     document.getElementById(divname).style.display = 'block';
     document.getElementById(divname+"plus").style.display="none";
     document.getElementById(divname+"minus").style.display="inline-block";
   }


   function clickminus(divname) {
     document.getElementById(divname).style.display = 'none';
     document.getElementById(divname+"plus").style.display="inline-block";
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

      // enable the one delete and disable the paste
      document.getElementById("pasteItem"+itemId).style.display = 'none';
      document.getElementById("title"+itemId).style.color = '#ff2222';

      return false;
   }

   function pasteItem(orderNo) {
     document.moveForm.pasteAfter.value = orderNo;
   }
   function reverse(orderNo) {
     document.moveForm.pasteAfter.value = orderNo;
   }

   function updateTrip(buttonName) {
    tripsStale=true;
     linkHandler(buttonName);

   }

// GPX file handling
   function site_add_gpx_file(gpxfield,wktfield) {
     site_wktfield=wktfield;
     site_fr.addEventListener('loadend',site_process_gpx_callback);
     site_fr.readAsText(document.getElementById(gpxfield).files[0]);
     if(site_fr.error) {
       alert('Cannot load file');
     } 
   }

   function site_process_gpx_callback() {
       map_GPXtoWKT(site_fr.result,site_wktfield);
       document.routeform.datasource.value="Uploaded from GPS";
       // redraw map
       route_init(document.routeform.route_startplace_location.value,
              document.routeform.route_endplace_location.value,
              document.routeform.route_location.value, 0);
   }
   function site_trim_route() {
       var route=document.routeform.route_location.value;
       var start=document.routeform.route_startplace_location.value;
       var end=document.routeform.route_endplace_location.value;
       route=map_trim_linestring_to_points(route,start,end);
       document.routeform.route_location.value=route;
       route_init(document.routeform.route_startplace_location.value,
              document.routeform.route_endplace_location.value,
              document.routeform.route_location.value, 0);
}


    function link_hyper_off()
    {
       $("#itemName").prop('readonly',true);
       document.getElementById("itemType").value='';
       document.getElementById("itemName").value='';
       document.getElementById("link-find").style.display="none";
       document.getElementById("hyperlinkon").style.display="block";
       document.getElementById("hyperlinkoff").style.display="none";
       return false;

    }

    function link_confirm(type,id, name)
    {
      document.getElementById("link-find").style.display="none";
      document.getElementById("searchon").style.display="block";
      document.getElementById("searchoff").style.display="none";
      document.getElementById("itemType").value=type ;
      document.getElementById("itemId").value=id ;
      document.getElementById("itemName").value=name ;
       return false;
    }

    function editcommenton()
    {
      document.getElementById("comment_form").style.display="block";
      document.getElementById("addComment").style.display="none";
       return false;
    }

    function editcommentoff()
    {
      document.getElementById("comment_form").style.display="none";
      document.getElementById("addComment").style.display="block";
       return false;

    }
    function link_search_on()
    {
       document.getElementById("link-find").style.display="block";
       document.getElementById("searchon").style.display="none";
       document.getElementById("searchoff").style.display="block";

       return false;

    }

    function link_search_off()
    {
       document.getElementById("link-find").style.display="none";
       document.getElementById("searchon").style.display="block";
       document.getElementById("searchoff").style.display="none";

       return false;
    }

    function link_hyper_on()
    {
       $("#itemName").prop('readonly',false);
       document.getElementById("itemType").value='URL';
       document.getElementById("hyperlinkon").style.display="none";
       document.getElementById("hyperlinkoff").style.display="block";

       return false;
    }

function link_select_on() {
  document.getElementById("link-select-on").style.display="none";
  document.getElementById("link-select-off").style.display="block";
  //document.selectform.select.value='';
  //document.selectform.selectname.value='';

  deactivate_all_click();
  map_on_click_activate(site_copy_link_callback);
//  map_enable_select_point();
}

function link_select_off() {
  document.getElementById("link-select-on").style.display="block";
  document.getElementById("link-select-off").style.display="none";

  deactivate_all_click();
}

function site_show_parks_layer() {
  document.getElementById("mapParks").style.backgroundColor="#008800";
  map_toggle_layer_by_name(true,'Parks');
  map_toggle_layer_by_name(true,'Parks Simple');
  map_toggle_layer_by_name(true,'Parks Very Simple');
}

function site_hide_parks_layer() {
  document.getElementById("mapParks").style.backgroundColor="#ffffff";
  map_toggle_layer_by_name(false,'Parks');
  map_toggle_layer_by_name(false,'Parks Simple');
  map_toggle_layer_by_name(false,'Parks Very Simple');
}

function site_toggle_beenthere(show) {
  if(site_current_userid || show==false) {
    if(typeof(show)=='undefined' || show==null) {
      site_show_beenthere=!site_show_beenthere;
      show=site_show_beenthere;
    }
  
    if (show) {
       document.getElementById("mapBeenthere").style.backgroundColor="#008800";
    } else {
       document.getElementById("mapBeenthere").style.backgroundColor="#ffffff";
    }
  
    map_toggle_layer_by_name(show,'My Places');
    map_toggle_layer_by_name(show,'My Routes');
    map_toggle_layer_by_name(show,'My Routes Simple');
  } else {
    if(typeof(show)=='undefined' || show==null) {
      alert("Sign up or sign in to log where you've been");
    }
  }
}


function site_toggle_parks_layer() {
  site_show_parks=!site_show_parks;

  if (site_show_parks) {
    site_show_parks_layer();
  } else {
    site_hide_parks_layer();
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

