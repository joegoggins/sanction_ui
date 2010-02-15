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
      flash[:notice] = "Record not found"
      redirect_to sanction_ui_roles_path and return
    end
  end  
    
  def index
    
    unless action_allowed? :can_view_permissions
      set_access_denied_flash(:can_view_permissions)
      redirect_to sanction_ui_access_denied_path and return false
    end
    # eager loaded for quick rendering
    @roles = Sanction::Role.find(:all, :include => [:principal, :permissionable], :order => 'name')
    
    # This below is a lil crazy--used to show when the permissions of the application
    # are being bypassed by other lists
    # essentially, we're walking over each role def and seeing if there are named_scope bypasses
    # on any given principal 
    @bypass_principals_for_role_definition = {}
    unless SanctionUi.bypass_named_scopes.empty?
      Sanction::Role::Definition.all_roles.each do |role_def|
        if (not SanctionUi.bypass_named_scopes[role_def.name].blank?) && SanctionUi.bypass_named_scopes[role_def.name].kind_of?(Array)
          SanctionUi.bypass_named_scopes[role_def.name].each do |bypass_hash|
            if bypass_hash[:named_scope].kind_of? Symbol
              role_def.principals.each do |principal|
                principal_klass = principal.constantize
                if principal_klass.respond_to? bypass_hash[:named_scope]                  
                  results = principal_klass.send(bypass_hash[:named_scope], {:role_definition => role_def, :bypass_hash => bypass_hash})
                  result_container = bypass_hash.dup
                  result_container[:results] = results
                  if @bypass_principals_for_role_definition[role_def.name].kind_of? Array
                    @bypass_principals_for_role_definition[role_def.name] << result_container
                  else
                    @bypass_principals_for_role_definition[role_def.name] = [result_container]
                  end
                end
              end
            else
              raise "only know how to do stuff with symbol refs for :named_scope, you had #{bypass_hash[:named_scope]}"
            end
          end          
        end
      end
    end
  end

  def new
    unless action_allowed? :can_add_role
      set_access_denied_flash(:can_add_role)
      redirect_to sanction_ui_access_denied_path and return false
    end
    
    @role = Sanction::Role.new :name => @role_definition.name
    
    respond_to do |format|
      format.html { }
      format.json { @role_definition }
    end
    
  end

  def create
    unless action_allowed? :can_add_role
      set_access_denied_flash(:can_add_role)
      redirect_to sanction_ui_access_denied_path and return false
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
    
    if params[:principal_all].blank?
      begin
        @principal_instance = @principal_class.find(params[:sanction_role][:principal_id])
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Error: Could not find a #{params[:sanction_role][:principal_type]} principal instance with id=#{params[:sanction_role][:principal_id]}"
        redirect_to sanction_ui_roles_path and return
      end      
    else
      @principal_instance = @principal_class
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
      
      if params[:permissionable_all].blank?
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
      else
        if @principal_instance.grant(@role_definition.name, @permissionable_class)
          flash[:notice] = "&quot;#{@role_definition.name.to_s.humanize}&quot; role successfully added over all #{@permissionable_class.to_s.humanize.pluralize}"
          redirect_to sanction_ui_roles_path and return
        else
          flash[:notice] = 'Role could not be added, may already be assigned to this user.'
          render :action => 'new' and return
        end
      end      
    end
  end

  def destroy
    @role = Sanction::Role.find(params[:id])
    unless action_allowed? :can_remove_role
      set_access_denied_flash(:can_remove_role)
      redirect_to sanction_ui_access_denied_path and return false
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
