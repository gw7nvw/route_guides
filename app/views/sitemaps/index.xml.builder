# app/views/sitemaps/index.xml.builder
xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
  @static_paths.each do |path|
    xml.url do
      xml.loc "#{root_url}#{path}"
      xml.changefreq("monthly")
      xml.priority("0.9")
    end
  end
  @places.each do |place|
    xml.url do
      xml.loc "#{root_url}places/#{place.id.to_s}"
      xml.lastmod place.affected_at.strftime("%F")
      xml.changefreq("monthly")
      xml.priority("1.0")
    end
  end
  @segments.each do |route|
    xml.url do
      xml.loc "#{root_url}routes/#{route.id.to_s}"
      xml.lastmod route.updated_at.strftime("%F")
      xml.changefreq("monthly")
      xml.priority("0.1")
    end
  end
  @trips.each do |trip|
    xml.url do
      xml.loc "#{root_url}trips/#{trip.id.to_s}"
      xml.lastmod trip.updated_at.strftime("%F")
      xml.changefreq("monthly")
      xml.priority("0.2")
    end
  end
  @stories.each do |report|
    xml.url do
      xml.loc "#{root_url}reports/#{report.id.to_s}"
      xml.lastmod report.updated_at.strftime("%F")
      xml.changefreq("monthly")
      xml.priority("0.2")
    end
  end
  @users.each do |user|
    xml.url do
      xml.loc "#{root_url}users/#{URI.encode(user.name)}"
      xml.lastmod user.updated_at.strftime("%F")
      xml.changefreq("monthly")
      xml.priority("0.2")
    end
  end
  @routes.each do |ri|
    url= 'search/?route_startplace_id='+ri.startplace_id.to_s+'&route_endplace_id='+ri.endplace_id.to_s
    url= 'routes/'+ri.url
    xml.url do
      xml.loc "#{root_url}#{url}"
      xml.lastmod ri.updated_at.strftime("%F")
      xml.changefreq("monthly")
      xml.priority("0.1")
    end
  end
end
