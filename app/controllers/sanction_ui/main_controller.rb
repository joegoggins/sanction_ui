class SanctionUi::MainController < SanctionUi::AuthController
  # This is the root of the sanction_ui plugin
  #
  def index
    unless action_allowed? :can_view_permissions
      redirect_to sanction_ui_access_denied_path(:can_view_permissions) and return
    end
  end

  # This describes how a role definition of params[:role_definition].name
  # is set up
  #
  def describe
    unless action_allowed? :can_describe_role
      redirect_to sanction_ui_access_denied_path(:can_describe_role) and return
    end
    @role_definition = Sanction::Role::Definition.all_roles.find do |x|
      x.name == params[:role_definition].to_sym
    end
    if @role_definition.blank?
      flash[:notice] = "Invalid role_definition"
      redirect_to(sanction_ui_roles_path) and return
    end
    
    respond_to do |format|
      format.html {}
      format.json  { @role_definition }
    end
  end

end
