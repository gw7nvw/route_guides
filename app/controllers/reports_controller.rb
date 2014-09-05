class ReportsController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create]
 before_action :touch_user


def new
    @edit=true
    @report=Report.new
end

def edit
    @edit=true
    if (!@id) then @id=params[:id] end
    @report=Report.find_by_id(@id)
end

def index
    @reports = Report.all.order(:name)
end

def show
    @edit=false
    if (!@id) then @id=params[:id] end
    @report=Report.find_by_id(@id)
end

def create
    @report = Report.new(report_params)

    #revision control
    @report.createdBy_id = @current_user.id #current_user.id
    @report.updatedBy_id = @current_user.id #current_user.id
    # but doesn;t handle location ... so

    if @report.save
      flash[:success] = "New report added, id:"+@report.id.to_s
      @edit=true

      #render edit panel to allow user to add links (can't do in create)
      @id=@report.id
      params[:id]=@id.to_s
      edit()
      render 'edit'
    else
      flash[:error] = "Error creating report"
      @edit=true
      render 'new'
    end
  end

def update
 if (params[:save])

    @report = Report.find(params[:id])

    @report.attributes=report_params

    #revision control
    @report.updatedBy_id = @current_user.id #current_user.id
    @report.updated_at = Time.new()

    if @report.save
        flash[:success] = "New report added, id:"+@report.id.to_s
        @id=@report.id
        #refresh variables
        show()

        #render show panel
        render 'show'
    else
      flash[:error] = "Error saving report"
      @edit=true
      render 'new'
    end
 end


 if (params[:delete])

         rls=ReportLink.where(report_id: params[:id])
         rls.each do |rl|
             rl.destroy
         end
         report=Report.find_by_id(params[:id])
         if report.destroy
           flash[:success] = "Report deleted, id:"+params[:id]
           redirect_to '/reports'
         else
           edit()
           render 'edit'
         end

  end

  #handles in javascript, so do nothing here as a fallback
 if (params[:select])
        @edit=true
      if (!@id) then @id=params[:id] end
      @report=Report.find_by_id(@id)

      render 'report_links'
 end


  if (params[:commit] and params[:commit][0..5] == 'confir')
      #add place/route to reportLinks
        rl=ReportLink.new()
        rl.report_id=params[:id]
        rl.item_type=params[:itemType]
        rl.item_id=params[:itemId]
      if(rl.item_type and rl.item_type.length>0 and rl.item_id and rl.item_id.>0)
        rl.save
      end
      @edit=true
      if (!@id) then @id=params[:id] end
      @report=Report.find_by_id(@id)
    
      render 'report_links'

  end

  if (params[:add])
      #add place/route to reportLinks
      #add place/route to reportLinks
        rl=ReportLink.new()
        rl.report_id=params[:id]
        rl.item_type='trip'
        rl.item_id=params[:report_link]['trip_id']
      if(rl.item_id and rl.item_id.to_i>0)
        rl.save
      end
      @edit=true
      if (!@id) then @id=params[:id] end
      @report=Report.find_by_id(@id)
    
      render 'report_links'

   end
  if (params[:commit] and params[:commit][0..5] == 'delete')
     report_link=ReportLink.find_by_id(params[:commit][6..-1].to_i)
     if (report_link)
        if(report_link.destroy)
           flash[:success] = "Removed link from report:"+params[:commit][6..-1]
        end
     else
        flash[:error] = "Cannot find link to delete:"+params[:commit][6..-1]
     end

     @edit=true
      if (!@id) then @id=params[:id] end
      @report=Report.find_by_id(@id)

      render 'report_links'

  end

end



  private
  def report_params
    params.require(:report).permit(:name, :description)
  end

end
