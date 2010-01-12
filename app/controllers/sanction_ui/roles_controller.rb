class SanctionUi::RolesController < SanctionUi::AuthController
  def index
    # eager loaded for quick rendering
    @roles = Sanction::Role.find(:all, :include => [:principal, :permissionable], :order => 'name')
  end

  def new
    if params[:global].blank?
    else
      @principles = Sanction.principals
    end
  end

  def create
  end

  def destroy
    @role = Sanction::Role.find(params[:id])
    render :inline => "NOT IMPLEMENTED Gonna delete <%= debug @role %>" and return
  end
end
