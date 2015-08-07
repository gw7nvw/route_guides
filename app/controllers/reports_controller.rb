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
    if params[:order]=='latest' then
      @order='latest'
      @reports=Report.order('updated_at desc').paginate(:per_page => 20, :page => params[:page])

    else
      @reports = Report.all.order(:name).paginate(:per_page => 20, :page => params[:page])
    end

end

def show
    @edit=false
    if params[:help] then @help=params[:help] end
    if params[:editlinks] then @editlinks=true end
    if (!@id) then @id=params[:id] end
    if !@report=Report.find_by_id(@id) then
      redirect_to root_url
    end
    @referring_page='/reports/'+@report.id.to_s

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
      show()
      render 'show'
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
        flash[:success] = "Report saved, id:"+@report.id.to_s
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

         report=Report.find_by_id(params[:id])
         links=report.links
         links.each do |l|
            l.destroy
         end

         if report.destroy
           flash[:success] = "Report deleted, id:"+params[:id]
           redirect_to '/reports'
         else
           edit()
           render 'edit'
         end

  end

  #handled in javascript, so do nothing here as a fallback
 if (params[:select])
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
