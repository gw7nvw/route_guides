# app/views/sitemaps/index.xml.builder
xml.instruct!
count=0
xml.huts do
  @places.each do |pl|
    legs=Route.find_by_sql [ "select * from routes where startplace_id="+pl.id.to_s+" or endplace_id="+pl.id.to_s ]
    routes=pl.adjoiningPlaceListFast
    hblink=Link.find_by_sql [ "select * from links where item_type='URL' and item_url like '%%hutbagger.co.nz%%' and \"baseItem_id\"="+pl.id.to_s ]
    xml.hut do

      xml.id pl.id
      xml.name pl.name
      xml.hb_url hblink.first.item_url
      xml.rg_url "http://routeguides.co.nz/places/"+pl.id.to_s
      xml.destination_count routes.count
      xml.route_count  legs.count
      if @view=="full"
        xml.destinations do
          routes.each do |rt|
            dest=Link.find_by_sql [ "select * from links where item_type='URL' and item_url like '%%hutbagger.co.nz%%' and \"baseItem_id\"="+rt.id.to_s ] 
            if dest.first then hburl=dest.first.item_url else hbrul="" end
            xml.destination do
              xml.name rt.name
              xml.rg_url  "http://routeguides.co.nz/places/"+rt.id.to_s
              xml.hb_url hburl
            end
          end
        end
        xml.routes do
          legs.each do |leg|
            xml.route do
              xml.name leg.name
              xml.rg_url "http://routeguides.co.nz/routes/"+leg.id.to_s
            end
          end
        end
      end
    end
  end
end
#  @routes.each do |ri|
#    url= 'search/?route_startplace_id='+ri.startplace_id.to_s+'&route_endplace_id='+ri.endplace_id.to_s
#    url= 'routes/'+ri.url
#    xml.url do
#      xml.loc "#{root_url}#{url}"
#      xml.lastmod ri.updated_at.strftime("%F")
#      xml.changefreq("monthly")
#      xml.priority("0.1")
#    end
#  end
