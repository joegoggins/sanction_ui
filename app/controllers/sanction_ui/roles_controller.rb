class SanctionUi::RolesController < SanctionUi::AuthController
  
  def index
    unless action_allowed? :can_view_roles?
      redirect_to sanction_ui_access_denied_path and return
    end
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
    if sui_check_against_current_user?
      current_user.has?
    else
    end

    render :inline => "NOT IMPLEMENTED Gonna delete <%= debug @role %>" and return
  end
end
