class SanctionUi::RolesController < SanctionUi::AuthController
  before_filter :load_role_definition, :only => [:new, :create]
  around_filter :catch_404ish_things
  
  def load_role_definition
    @role_definition = Sanction::Role::Definition.all_roles.find do |x|
      x.name == params[:role_definition].to_sym
    end

    if @role_definition.blank?
      flash[:notice] = "Invalid role definition name"
      redirect_to(sanction_ui_roles_path) and return
    end
  end
  
  def catch_404ish_things
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
    unless action_allowed? :can_add_role
      redirect_to sanction_ui_access_denied_path and return
    end
    
    @role = Sanction::Role.new :name => @role_definition.name
    
    respond_to do |format|
      format.html { }
      format.json { @role_definition }
    end
    
  end

  def create
    unless action_allowed? :can_add_role
      redirect_to sanction_ui_access_denied_path and return
    end
    @role = Sanction::Role.new params[:sanction_role]
    begin
      @principal_class = params[:sanction_role][:principal_type].constantize      
    rescue NameError => e
      if @role_definition.blank?
        flash[:notice] = "Error: Invalid principal type class"
        redirect_to(sanction_ui_roles_path) and return
      end
    end
    
    begin
      @principal_instance = @principal_class.find(params[:sanction_role][:principal_id])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Error: Could not find a #{params[:sanction_role][:principal_type]} principal instance with id=#{params[:sanction_role][:principal_id]}"
      redirect_to sanction_ui_roles_path and return
    end
    
    if @role_definition.global?
      if @principal_instance.grant(@role_definition.name)
        flash[:notice] = "&quot;#{@role_definition.name.to_s.humanize}&quot; role successfully added."
        redirect_to sanction_ui_roles_path and return
      else
        flash[:notice] = 'Role could not be added, may already be assigned to this user, or is an inavlid ID.'
        render :action => 'new' and return
      end
    else
      begin
        @permissionable_class = params[:sanction_role][:permissionable_type].constantize      
      rescue NameError => e
        if @role_definition.blank?
          flash[:notice] = "Error: Invalid permissionable type class #{params[:sanction_role][:permissionable_type]}"
          redirect_to(sanction_ui_roles_path) and return
        end
      end

      begin
        @permissionable_instance = @permissionable_class.find(params[:sanction_role][:permissionable_id])
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Error: Could not find a #{params[:sanction_role][:permissionable_type]} permissionable instance with id=#{params[:sanction_role][:permissionable_id]}"
        redirect_to sanction_ui_roles_path and return
      end
      
      if @principal_instance.grant(@role_definition.name, @permissionable_instance)
        flash[:notice] = "&quot;#{@role_definition.name.to_s.humanize}&quot; role successfully added over #{@permissionable_instance.send(SanctionUi.permissionables_to_s_method)}"
        redirect_to sanction_ui_roles_path and return
      else
        flash[:notice] = 'Role could not be added, may already be assigned to this user, or is an inavlid ID.'
        render :action => 'new' and return
      end
    end
  end

  def destroy
    @role = Sanction::Role.find(params[:id])
    unless action_allowed? :can_remove_role
      redirect_to sanction_ui_access_denied_path(:role => @role) and return
    end

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
