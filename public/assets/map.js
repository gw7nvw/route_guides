var map_map;

            // we want opaque external graphics and non-opaque internal graphics

var vectorLayer;
var renderer;

var layer_style;
var click;
var style_blue;
var style_hut;
var style_pt_default;
var pt_styleMap;

function init(){
  if(typeof(map_map)=='undefined') {
    /* add the click controlif it has been defined onthis page */
    if(typeof(OpenLayers.Control.Click)!='undefined')     click = new OpenLayers.Control.Click();

    /* explicityly define the projections we will use */
    Proj4js.defs["EPSG:2193"] = "+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
    Proj4js.defs["EPSG:900913"] = "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs";

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

    map_map = new OpenLayers.Map( 'map_map', {
            displayProjection: new OpenLayers.Projection("EPSG:2193"),
            projection: new OpenLayers.Projection("EPSG:900913")
    } );

    Proj4js.Proj.tmerc = {
      init : function() {
        this.e0 = Proj4js.common.e0fn(this.es);
        this.e1 = Proj4js.common.e1fn(this.es);
        this.e2 = Proj4js.common.e2fn(this.es);
        this.e3 = Proj4js.common.e3fn(this.es);
        this.ml0 = this.a * Proj4js.common.mlfn(this.e0, this.e1, this.e2, this.e3, this.lat0);
      },

  /**
    Transverse Mercator Forward  - long/lat to x/y
    long/lat in radians
  */
  forward : function(p) {
    var lon = p.x;
    var lat = p.y;

    var delta_lon = Proj4js.common.adjust_lon(lon - this.long0); // Delta longitude
    var con;    // cone constant
    var x, y;
    var sin_phi=Math.sin(lat);
    var cos_phi=Math.cos(lat);

    if (this.sphere) {  /* spherical form */
      var b = cos_phi * Math.sin(delta_lon);
      if ((Math.abs(Math.abs(b) - 1.0)) < .0000000001)  {
        Proj4js.reportError("tmerc:forward: Point projects into infinity");
        return(93);
      } else {
        x = .5 * this.a * this.k0 * Math.log((1.0 + b)/(1.0 - b));
        con = Math.acos(cos_phi * Math.cos(delta_lon)/Math.sqrt(1.0 - b*b));
        if (lat < 0) con = - con;
        y = this.a * this.k0 * (con - this.lat0);
      }
    } else {
      var al  = cos_phi * delta_lon;
      var als = Math.pow(al,2);
      var c   = this.ep2 * Math.pow(cos_phi,2);
      var tq  = Math.tan(lat);
      var t   = Math.pow(tq,2);
      con = 1.0 - this.es * Math.pow(sin_phi,2);
      var n   = this.a / Math.sqrt(con);
      var ml  = this.a * Proj4js.common.mlfn(this.e0, this.e1, this.e2, this.e3, lat);

      x = this.k0 * n * al * (1.0 + als / 6.0 * (1.0 - t + c + als / 20.0 * (5.0 - 18.0 * t + Math.pow(t,2) + 72.0 * c - 58.0 * this.ep2))) + this.x0;
      y = this.k0 * (ml - this.ml0 + n * tq * (als * (0.5 + als / 24.0 * (5.0 - t + 9.0 * c + 4.0 * Math.pow(c,2) + als / 30.0 * (61.0 - 58.0 * t + Math.pow(t,2) + 600.0 * c - 330.0 * this.ep2))))) + this.y0;

    }
    p.x = x; p.y = y;
    return p;
  }, // tmercFwd()

  /**
    Transverse Mercator Inverse  -  x/y to long/lat
  */
  inverse : function(p) {
    var con, phi;  /* temporary angles       */
    var delta_phi; /* difference between longitudes    */
    var i;
    var max_iter = 6;      /* maximun number of iterations */
    var lat, lon;

    if (this.sphere) {   /* spherical form */
      var f = Math.exp(p.x/(this.a * this.k0));
      var g = .5 * (f - 1/f);
      var temp = this.lat0 + p.y/(this.a * this.k0);
      var h = Math.cos(temp);
      con = Math.sqrt((1.0 - h * h)/(1.0 + g * g));
      lat = Proj4js.common.asinz(con);
      if (temp < 0)
        lat = -lat;
      if ((g == 0) && (h == 0)) {
        lon = this.long0;
      } else {
        lon = Proj4js.common.adjust_lon(Math.atan2(g,h) + this.long0);
      }
    } else {    // ellipsoidal form
      var x = p.x - this.x0;
      var y = p.y - this.y0;

      con = (this.ml0 + y / this.k0) / this.a;
      phi = con;
      for (i=0;true;i++) {
        delta_phi=((con + this.e1 * Math.sin(2.0*phi) - this.e2 * Math.sin(4.0*phi) + this.e3 * Math.sin(6.0*phi)) / this.e0) - phi;
        phi += delta_phi;
        if (Math.abs(delta_phi) <= Proj4js.common.EPSLN) break;
        if (i >= max_iter) {
          Proj4js.reportError("tmerc:inverse: Latitude failed to converge");
          return(95);
        }
      } // for()
      if (Math.abs(phi) < Proj4js.common.HALF_PI) {
        // sincos(phi, &sin_phi, &cos_phi);
        var sin_phi=Math.sin(phi);
        var cos_phi=Math.cos(phi);
        var tan_phi = Math.tan(phi);
        var c = this.ep2 * Math.pow(cos_phi,2);
        var cs = Math.pow(c,2);
        var t = Math.pow(tan_phi,2);
        var ts = Math.pow(t,2);
        con = 1.0 - this.es * Math.pow(sin_phi,2);
        var n = this.a / Math.sqrt(con);
        var r = n * (1.0 - this.es) / con;
        var d = x / (n * this.k0);
        var ds = Math.pow(d,2);
        lat = phi - (n * tan_phi * ds / r) * (0.5 - ds / 24.0 * (5.0 + 3.0 * t + 10.0 * c - 4.0 * cs - 9.0 * this.ep2 - ds / 30.0 * (61.0 + 90.0 * t + 298.0 * c + 45.0 * ts - 252.0 * this.ep2 - 3.0 * cs)));
        lon = Proj4js.common.adjust_lon(this.long0 + (d * (1.0 - ds / 6.0 * (1.0 + 2.0 * t + c - ds / 20.0 * (5.0 - 2.0 * c + 28.0 * t - 3.0 * cs + 8.0 * this.ep2 + 24.0 * ts))) / cos_phi));
      } else {
        lat = Proj4js.common.HALF_PI * Proj4js.common.sign(y);
        lon = this.long0;
      }
    }
    p.x = lon;
    p.y = lat;
    return p;
  } // tmercInv()
};


    renderer = OpenLayers.Util.getParameters(window.location.href).renderer;
    renderer = (renderer) ? [renderer] : OpenLayers.Layer.Vector.prototype.renderers;

    vectorLayer = new OpenLayers.Layer.Vector("Current Item", {
                renderers: renderer
    }); 
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

/*    places_layer = new OpenLayers.Layer.MapServer( "Places",
            "http://wharncliffe.co.nz/cgi-bin/mapserv", {layers: 'places', map: '/ms4w/apps/matts_app/htdocs/example1-5.map'},
            {gutter: 15, transparent: true, isBaseLayer: false}); */
/*      places_layer = new OpenLayers.Layer.Vector( "Places",
                "http://wharncliffe.co.nz/cgi-bin/mapserv?map=/ms4w/apps/matts_app/htdocs/example1-5.map",
				{ typename: 'places' },
				{ extractAttributes: true }); */
            
      places_layer = new OpenLayers.Layer.Vector("Places", {
                    strategies: [new OpenLayers.Strategy.BBOX()],
                    protocol: new OpenLayers.Protocol.WFS({
                        url:  "http://wharncliffe.co.nz/cgi-bin/mapserv?map=/ms4w/apps/matts_app/htdocs/example1-5.map",
                        featureType: "places",
                        extractAttributes: true
                    }),
                    styleMap: pt_styleMap
                }); 

 //callback after a layer has been loaded in openlayers
    places_layer.events.register("loadend", places_layer, function() { 
           tooltip();
    });

    map_map.addLayer(test_g_wmts_layer);
    map_map.addLayer(places_layer);
    map_map.addLayer(vectorLayer);


    map_map.zoomToExtent(extent);
    map_map.addControl(new OpenLayers.Control.LayerSwitcher());
    map_map.addControl(new OpenLayers.Control.MousePosition());
    if(typeof(click)!='undefined') 
    {
      map_map.addControl(click);
    } 
        // Create a select feature control and add it to the map.
            var select = new OpenLayers.Control.SelectFeature(places_layer, {hover: true});
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



