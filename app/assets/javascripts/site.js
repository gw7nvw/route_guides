var clickMode;
var searchMode;
var site_map_size=1;
var site_selected_layer;
var places_layer;
var routes_layer;
var routes_simple_layer;
var site_route_classifier="routetype_id";
var site_rt_styles=[];
var site_pt_styles=[];
var site_map_pinned=false;
var site_routesStale=false;
var site_placesStale=false;
var site_select_id_dest;
var site_select_name_dest;
var site_current_style=null;

//styles
var site_blue_dot;
var site_purple_star;
var site_red_star;
var site_green_star;
var site_red_line;
// Site-specfic stuff follows - should be in separate file
//

function site_init() {
  if(typeof(map_map)=='undefined') {
    site_init_styles();
    map_init_mapspast('map_map');
    site_create_default_rt_styles();
    site_create_pt_styles();
    site_add_vector_layers();
  
    map_map.addLayer(map_scratch_layer);
    map_add_tooltip();
    map_on_click_activate(map_navigate_on_click_callback);
    if ($(window).width() < 960) {
      site_smaller_map();
    }
    if(typeof(def_x)!='undefined' && typeof(def_y)!='undefined') {
       var centre='POINT('+def_x+' '+def_y+')';
       map_centre(centre,'EPSG:2193');
    }
    if(typeof(def_zoom)!='undefined') {
       map_zoom(def_zoom);
    }
  }
}

function site_add_vector_layers() {
  places_layer=map_add_vector_layer("Places", "http://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "places",site_point_style_function,true,8,32);
  routes_layer=map_add_vector_layer("Routes", "http://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "routes",site_route_style_function,true,8,32);
  routes_simple_layer=map_add_vector_layer("Routes Simple", "http://routeguides.co.nz/cgi-bin/mapserv?map=/var/www/html/rg_maps/rg_map.map", "routes-simple",site_route_style_function,true,1,8);
  map_map.addLayer(places_layer);
  map_map.addLayer(routes_layer);
  map_map.addLayer(routes_simple_layer);

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
	map_add_raster_layer('NZTM Topo 2009', 'http://au.mapspast.org.nz/topo50/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
	map_add_raster_layer('NZMS260 1999', 'http://au.mapspast.org.nz/nzms260-1999/{z}/{x}/{-y}.png', 'mapspast', 4891.969809375, 11);
	map_add_raster_layer('NZMS1/260 1989','http://au.mapspast.org.nz/nzms-1989/{z}/{x}/{-y}.png','mapspast', 4891.969809375, 11);
	map_add_raster_layer('NZMS1 1979', 'http://au.mapspast.org.nz/nzms-1979/{z}/{x}/{-y}.png','mapspast', 4891.969809375, 11);
        map_add_raster_layer('NZMS1 1969','http://au.mapspast.org.nz/nzms-1969/{z}/{x}/{-y}.png','mapspast', 4891.969809375, 11);
        map_add_raster_layer('NZMS1 1959','http://au.mapspast.org.nz/nzms-1959/{z}/{x}/{-y}.png','mapspast',4891.969809375, 11);
        map_add_raster_layer('NZMS15 1949','http://au.mapspast.org.nz/nzms15-1949/{z}/{x}/{-y}.png','mapspast',4891.969809375, 11);
        map_add_raster_layer('NZMS13 1939','http://au.mapspast.org.nz/nzms13-1939/{z}/{x}/{-y}.png','mapspast',4891.969809375, 11); 
        map_add_raster_layer('NZMS13 1929','http://au.mapspast.org.nz/nzms13-1929/{z}/{x}/{-y}.png','mapspast',4891.969809375, 11);
        map_add_raster_layer('NZMS13 1919','http://au.mapspast.org.nz/nzms13-1919/{z}/{x}/{-y}.png','mapspast',4891.969809375, 11);
        map_add_raster_layer('NZMS13 1909','http://au.mapspast.org.nz/nzms13-1909/{z}/{x}/{-y}.png','mapspast',4891.969809375, 11);
        map_add_raster_layer('NZMS13 1899','http://au.mapspast.org.nz/nzms13-1899/{z}/{x}/{-y}.png','mapspast',4891.969809375, 11);
        map_add_raster_layer('(LINZ) Topo50 latest','http://tiles-a.data-cdn.linz.govt.nz/services;key=d8c83efc690a4de4ab067eadb6ae95e4/tiles/v4/layer=767/EPSG:2193/{z}/{x}/{y}.png','linz',8690, 17);
        map_add_raster_layer('(LINZ) Airphoto latest','http://tiles-a.data-cdn.linz.govt.nz/services;key=d8c83efc690a4de4ab067eadb6ae95e4/tiles/v4/set=2/EPSG:2193/{z}/{x}/{y}.png','linz',8690, 17);
}

function site_add_controls() {
	map_create_control("/assets/key24.png","Show Legend / Configure map",site_mapKey,"mapKey");
	map_create_control("/assets/layers24.png","Select basemap",map_mapLayers,"mapLayers");
	map_create_control("/assets/pin24.png","Pin map (do not automatically recentre)",site_pinMap,"mapPin");
	map_create_control("/assets/target24.png","Centre map on current item",site_centreMap,"mapCentre");
	map_create_control("/assets/save24.png","Save / print current map",site_printMap,"mapPrint");
}

function site_bigger_map() {
  document.getElementById('map_map').style.display="none";
  if (site_map_size==1) {
    $('#left_panel').toggleClass('span5 span12');
    $('#right_panel').toggleClass('span7 span0');
  setTimeout( function() {document.getElementById('right_panel').style.display="none";}, 100);
    site_map_size=2;
  }

  if (site_map_size==0) {
    $('#left_panel').toggleClass('span0 span5');
    $('#right_panel').toggleClass('span12 span7');
    document.getElementById('left_panel').style.display="block";
    site_map_size=1;
  }
  setTimeout( function() {
    map_map.updateSize();
    document.getElementById('map_map').style.display="block";
    setTimeout( function() { map_map.updateSize(); }, 1000);
    map_map.updateSize();
  }, 200);
  return false ;
}

function site_smaller_map() {
  document.getElementById('map_map').style.display="none";
  if (site_map_size==1) {
    $('#left_panel').toggleClass('span5 span0');
    $('#right_panel').toggleClass('span7 span12');
    document.getElementById('left_panel').style.display="none";
    site_map_size=0;
  }
  if (site_map_size==2) {
    document.getElementById('right_panel').style.display="block";
    $('#left_panel').toggleClass('span12 span5');
    $('#right_panel').toggleClass('span0 span7');
    site_map_size=1;
  }

  setTimeout( function() {
    map_map.updateSize();
    document.getElementById('map_map').style.display="block";
    setTimeout( function() { map_map.updateSize(); }, 1000);
    map_map.updateSize();
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

function linkHandler(entity_name) {
    /* close the dropdown */
    $('.dropdown').removeClass('open');

    /* show 'loading ...' */
    document.getElementById("page_status").innerHTML = 'Loading ...'

    $(function() {
     $.rails.ajax = function (options) {
       options.tryCount= (!options.tryCount) ? 0 : options.tryCount;0;
       options.timeout = 5000*(options.tryCount+1);
       options.retryLimit=1;
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
           document.getElementById("page_status").innerHTML = 'Error';
         }
         if(thrownError=="success") {
           if(site_map_size==0) site_bigger_map();
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




function site_printMap(filetype) {
  alert('Feature currently disabled');
  return 1;
  filetype='jpg';
  var extent=map_map.getView().calculateExtent();
  var xl=extent[0];
  var xr=extent[2];
  var yt=extent[1];
  var yb=extent[3];
  var width=document.selectform.pix_width.value;
  var height=document.selectform.pix_height.value;
  layerid=map_current_layer;
  sheetid=document.extentform.layerid.value;
  var maxzoom=document.extentform.maxzoom.value;
  var filename=document.selectform.filename.value;
  if (document.extentform.serverpath.value=="http://mapspast.org.nz/") {
    window.open('http://mapspast.org.nz/assets/print.html?print=true&left='+xl+'&right='+xr+'&top='+yt+'&bottom='+yb+'&sheetid='+sheetid+'&layerid='+layerid+'&wwidth='+width+'&wheight='+height+'&maxzoom='+maxzoom+'&filetype='+filetype+'&filename='+filename, 'printwindow');

  } else {
    window.open('http://au.mapspast.org.nz/print.html?print=true&left='+xl+'&right='+xr+'&top='+yt+'&bottom='+yb+'&sheetid='+sheetid+'&layerid='+layerid+'&wwidth='+width+'&wheight='+height+'&maxzoom='+maxzoom+'&filetype='+filetype+'&filename='+filename, 'printwindow');
  }
  return false;
}

function site_init_styles() {
  site_blue_dot=map_create_style("circle", 3, "#2222ff", "#22ffff", 1);
  site_purple_star=map_create_style("star", 10, "#8b008b", "#8b008b", 1);
  site_red_star=map_create_style("star", 10, "#990000","#990000", 1);
  site_green_star=map_create_style("star", 10, "#009900", "#009900", 1);
  site_red_line=map_create_style("", null, "#990000", "#990000", 4);

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
     "Bridge": map_create_style('cross',4,'#414141','#414141',1),
     "Campsite": map_create_style('circle',3,'#00ffff','#00ffff',1),
     "Campspot": map_create_style('circle',3,'#00ff00','#00ff00',1),
     "Hut": map_create_style('circle',3,'#0000ff','#0000ff',1),
     "Junction": map_create_style('square',2,'#00003d','#00003d',1),
     "Locality": map_create_style('square',3,'#000000','#000000',1),
     "Lookout": map_create_style('circle',3,'#414141','#414141',1),
     "Other": map_create_style('square',3,'#00003d','#00003d',1),
     "Pass": map_create_style('triangle',4,'#333300','#333300',1),
     "River Crossing": map_create_style('x',4,'#414141','#414141',1),
     "Rock Biv": map_create_style('cross',4,'#414141','#414141',1),
     "Roadend": map_create_style('square',3,'#1a1a1a','#1a1a1a',1),
     "Summit": map_create_style('triangle',4,'#b26b00','#b26b00',1),
     "Waterbody": map_create_style('x',4,'#000099','#000099',1)
  };
}

function reset_map_controllers() {

//deactiavte all other click controllers
  if(typeof(map_map)!='undefined') {
     deactivate_all_click();
     map_on_click_activate(map_navigate_on_click_callback);
     map_clear_scratch_layer();
     map_map.updateSize();
  }
//set status icon to show click to navigate
}

function deactivate_all_click() {

  if(typeof(map_map)!='undefined') map_on_click_deactivate(map_navigate_on_click_callback);
  if(typeof(map_map)!='undefined') map_on_click_deactivate(site_select_point_on_click_callback);
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

function site_selectPlace(id_loc, name_loc, disable_icon, enable_icon, style) {
  deactivate_all_click();
  document.getElementById(enable_icon).style.display="none";
  document.getElementById(disable_icon).style.display="block";

  map_on_click_activate(site_select_point_on_click_callback);
  
  site_select_id_dest=id_loc;
  site_select_name_dest=name_loc;
  site_current_style=style;
}

function site_selectNothing(disable_icon, enable_icon) {
  document.getElementById(enable_icon).style.display="block";
  document.getElementById(disable_icon).style.display="none";
  deactivate_all_click();
  site_select_name_dest=null
  site_select_id_dest=null;
  site_current_style=null;
}

function site_select_point_on_click_callback(evt) {
    var pixel = evt.pixel;
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
  
      //now mark it on map
      if(site_current_style!=null) {
           map_clear_scratch_layer('Point', site_current_style);
         var coordinate=evt.coordinate;
         map_add_feature_from_wkt('POINT('+coordinate[0]+' '+coordinate[1]+')', 'EPSG:2193', site_current_style);
      }
    }
}

function site_drawPlace(disable_icon, enable_icon, place_loc, place_x, place_y) {
  deactivate_all_click();
  document.getElementById(enable_icon).style.display="none";
  document.getElementById(disable_icon).style.display="block";

  //map_clear_scratch_layer();
  map_enable_draw("Point",site_purple_star,place_loc, place_x ,place_y  ,true);
}

function site_drawRoute(disable_icon, enable_icon) {
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

   function updateTrip(buttonName) {
    tripsStale=true;
     linkHandler(buttonName);

   }

// GPX file handloing
   function copyGpx() {

     map_GPXtoWKT('gpxfield', 'route_location');
     document.routeform.datasource.value="Uploaded from GPS";
     // redraw map
     route_init(document.routeform.route_startplace_location.value,
              document.routeform.route_endplace_location.value,
              document.routeform.route_location.value, 0);

}


