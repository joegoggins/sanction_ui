class SanctionUi::RolesController < SanctionUi::AuthController
  around_filter :catch_bullshit
  
  def catch_bullshit
    begin
      yield
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "That role no longer exists."
      redirect_to sanction_ui_roles_path and return
    end
  end  
    
  def index
    unless action_allowed? :can_view_sui_roles_index
      redirect_to sanction_ui_access_denied_path and return
    end
    # eager loaded for quick rendering
    @roles = Sanction::Role.find(:all, :include => [:principal, :permissionable], :order => 'name')
  end

  def new
    @role_definition = Sanction::Role::Definition.all_roles.find do |x|
      x.name == params[:role_definition].to_sym
    end
    
    
    respond_to do |format|
      format.html { 
        if @role_definition.blank?
          flash[:notice] = "Invalid role definition name"
          redirect_to(sanction_ui_roles_path) 
        # OTHERWISE--render the dang form in roles/new.html.erb (implied)
        end
        }
      format.json { @role_definition }
    end
    
  end

  def create
  end

  # Assumes @role or @role_definition is set
  #
  def deny_access_if_needed(method)
    case method
    when :destroy
      unless action_allowed? :can_remove_role
        redirect_to sanction_ui_access_denied_path(:role => @role) and return
      end
    end
  end

  def destroy
    @role = Sanction::Role.find(params[:id])
    deny_access_if_needed(:destroy)

    if @role.destroy
      flash[:notice] = 'Role successfully removed.'
    else
      flash[:notice] = 'Role could not be removed.'
    end
    
    respond_to do |format|
      format.html { redirect_to(sanction_ui_roles_path) }
      format.json { flash[:notice] }
    end
  end
end
