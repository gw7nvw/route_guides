class CatchmentsController < ApplicationController

def index

    @order=params[:order]

    if params[:order]=='latest' then
      @catchments=Catchment.all.order('updated_at desc').paginate(:per_page => 80, :page => params[:page])
    else
      @catchments = Catchment.all.order('name').paginate(:per_page => 80, :page => params[:page])
    end

end


def show

   @catchment=Catchment.first

end

end
