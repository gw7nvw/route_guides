class ReportsController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create]

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
    @report_instance=ReportInstance.new(@report.attributes)
    # but doesn;t handle location ... so

    if @report.save
      @report_instance.report_id=@report.id
      if @report_instance.save
        flash[:success] = "New report added, id:"+@report.id.to_s
        @id=@report.id
        #refresh variables
        show()

        #render show panel
        render 'show'

      else
        # Handle an unsuccessful save.
        flash[:error] = "Error creating instance"
        @edit=true
        render 'new'
      end
    else
      flash[:error] = "Error creating report"
      @edit=true
      render 'new'
    end
  end

def update
 if (params[:save])

    @report = Report.find(params[:id])

    @report.update(report_params)

    #revision control
    @report.createdBy_id = @current_user.id #current_user.id
    @report_instance=ReportInstance.new(@report.attributes)
    @report_instance.id=nil
    # but doesn;t handle location ... so

    if @report.save
      @report_instance.report_id=@report.id
      if @report_instance.save
        flash[:success] = "New report added, id:"+@report.id.to_s
        @id=@report.id
        #refresh variables
        show()

        #render show panel
        render 'show'

      else
        # Handle an unsuccessful save.
        flash[:error] = "Error creating instance"
        @edit=true
        render 'new'
      end
    else
      flash[:error] = "Error saving report"
      @edit=true
      render 'new'
    end
end
 if (params[:delete])

         report=Report.find_by_id(params[:id])
         if report.destroy
           flash[:success] = "Report deleted, id:"+params[:id]
           redirect_to '/reports'
         else
           edit()
           render 'edit'
         end

  end

  end


  private
  def report_params
    params.require(:report).permit(:name, :description)
  end

end
