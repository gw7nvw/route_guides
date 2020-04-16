class ExtractsController < ApplicationController
  #caches_page :index
  def index
    @all_links=Link.find_by_sql [ "select * from links where item_type='URL' and item_url like '%%hutbagger.co.nz%%' " ]
    pli=@all_links.collect{|u| u.baseItem_id}



    @places=Place.where(id: pli)


    respond_to do |format|
        format.xml  do
        end
    end
  end

  def index_full
    @view="full"
    index()
    render 'index'
  end

  def index_brief
    @view="brief"
    index()
    render 'index'
  end
end
