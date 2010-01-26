class SanctionUi::MainController < SanctionUi::AuthController
  # This is the root of the /sanction_ui plugin
  #
  def index
    #TODO: Access control
  end

  # This describes how a role definition of params[:role_definition].name
  # is set up
  #
  def describe
    #TODO: Access control
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
