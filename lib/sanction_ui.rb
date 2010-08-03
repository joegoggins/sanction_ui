module SanctionUi  
  mattr_accessor :plugin_base_path, :asset_override_base_path, :route_url_prefix, :labels,
  # Set to false if you want your access denied page to
  # say nothing to users about why they were denied access
  # Will use @role_definition.purpose for the string to describe.
  #
  :describe_on_deny,
  
  # Will provide additional information about what the role was scoped to
  # when access is denied
  :describe_over_on_deny,
  # Will display on access denied form if both are not blank and describe_on_deny is true
  #
  :denied_contact_label,
  :denied_contact_email,  
  
  :role_bypasses,
  
  # This affects the behavior of `redirect_to_access_denied_if_cannot` in your controllers and views
  # if true this will change the permission check methodology to do things in memory via eager_has? and eager_has_over?
  # instead of the named_scope based approach
  :assume_eager_loaded_principal_roles,
  
  # Sanction allows weird things like AppUser.grant(:some_role), which then allows ALL AppUser rows
  # to have that role--it's kind of weird, and will likely be deprecated in future releases, it's confusing
  # and does not need UI (i dont think), sanction_ui does process this option via the principal_all and permissionable_all partials,
  # Since its confusing, I'm adding this to ignore
  # 
  :disable_principal_blanket_attribution,
  :disable_permissionable_blanket_attribution

  mattr_reader :principal_to_s_methods, :permissionable_to_s_methods, :has_been_configured, :install_instructions, :special_permissions
  

  def self.configure
    self.set_defaults
    return if @@has_been_configured
    yield self
    @@has_been_configured = true
  end

  def self.set_defaults
    @@has_been_configured = false
    @@plugin_base_path = "vendor/plugins/sanction_ui"
    @@asset_override_base_path = "app/views/sanction_ui/assets"
    @@route_url_prefix = '/permissions'
    @@labels = {:can_add_role => "add",
       :can_remove_role => "remove", 
       :can_describe_role => "describe",
       :confirm_remove_role => 'You sure?',
       :over => 'over',
       :principal_type => 'Principal Type: ',
       :principal_id => "Principal ID: ", 
       :principal_all => "Check to add role over all instances of this type",
       :permissionable_type => 'Permissionable Type: ',
       :permissionable_id => "Permissionable ID: ",
       :permissionable_all => "Check to add role over all instances of this type",
       :access_denied => 'Access Denied',
       # What gets shown in the title of pages
       :sanction_ui_title => 'Permissions Management System',
       :roles_index_title => "Listing all permissions by role",
       :roles_explicit_only_title => "Listing only explicitly granted permissions by role"
    }
    @@describe_on_deny = true
    @@describe_over_on_deny = true
    @@denied_contact_label = ""
    @@denied_contact_email = ""
    @@principal_to_s_methods = {} 
    @@permissionable_to_s_methods = {}
    @@role_bypasses = {}
    @@assume_eager_loaded_principal_roles = false # TODO: deprecate        
    @@disable_principal_blanket_attribution = true
    @@disable_permissionable_blanket_attribution = true
    
    @@special_permissions = {
      :can_view_permissions => "Show the root page of sanction_ui AND
      The main roles/index page where permissions management happens.
      ",
      :can_add_role => "
      Used to check who can add roles--see SanctionUi::AuthController in your app
      for additional options
      ",
      :can_remove_role => "
      Used to check who can remove roles--see SanctionUi::AuthController in your app
      for additional options
      ",  
      :can_describe_role => "
      Describes all of the configuration for a particular role
      "  
    }
    
    @@install_instructions = <<-EOS
    
    SANCTION UI INSTALL INSTRUCTIONS:
    =================================

    1. Add a role or permissions in config/initializers/sanction.rb  
       most of the time it ends up looking something like:
         config.role :permission_manager, 
                     User => :global, 
                     :having => [:#{self.special_permissions.keys.join(',:')}], 
                     :purpose => "to manage who can access what in the application"
                     
    2. Add a user to this role in the console (or create a migration and add this)
      @the_permission_manager = User.find(:first)
      @the_permission_manager.grant(:permission_manager)
      
    3. Implement a method in ApplicationController, something like:
       def current_principal
   	    @current_principal ||= User.find(:first) 
   	   end
   	   helper_method :current_principal

    4. Restart Rails server and hit /permissions in a browser
    
    5. Further customization can happen in your app in:
         # Access denied helper, add this to ApplicationController
            include SanctionUi::ApplicationController::Helpers
         # will allow access control like this your controllers:
           return false if redirect_to_access_denied_if_cannot(:can_show, @thing)
           
         # Basic permissions system config see sanction documentation
         config/initializers/sanction.rb
         
         # How sanction permissions manifest in the UI
         config/initializers/sanction_ui.rb
         
         # Custom access control rules for the permissions management UI, stuff like:
         #   * super_users can create any other user, no-one else can.
         #   * my boss/client cannot be deleted.
         app/controllers/sanction_ui/auth_controller.rb
         
         # Override appearance of anything in UI
         #   * HTML partials from app/views/sanction_ui/main or app/views/sanction_ui/roles
         #   * CSS and JS overrides in to app/views/sanction_ui/assets (note, they don't live in /public and can interpolate like ERB if you want)
    EOS
  end
  
  def self.set_principal_to_s_method(klass, method)
    if klass.kind_of? String
      klass = klass.constantize
    end
    
    if SanctionUi.is_valid_principal?(klass)
      @@principal_to_s_methods[klass.to_s] = method
    else
      raise "Sanction Ui Error: Invalid principal"
    end
  end

  def self.set_permissionable_to_s_method(klass, method)
    if klass.kind_of? String
      klass = klass.constantize
    end
    if SanctionUi.is_valid_permissionable?(klass)
      @@permissionable_to_s_methods[klass.to_s] = method
    else
      raise "Sanction Ui Error: Invalid permissionable"
    end
  end
  
  def self.add_bypass(role_name, options)
    @@role_bypasses[role_name] ||= []
    @@role_bypasses[role_name] << options
  end
  
  # To override one label
  def self.set_label(key,value)
    if labels[key.to_sym].blank?
      raise "Invalid label key"
    else
      self.labels[key] = value
    end
  end
  
  
  def self.is_valid_principal?(principal_class_or_instance)
    if principal_class_or_instance.class == Class
      principal_class_or_instance.included_modules.include? Sanction::Principal
    else
      principal_class_or_instance.class.included_modules.include? Sanction::Principal
    end
  end
  
  def self.is_valid_permissionable?(permissionable_class_or_instance)
    if permissionable_class_or_instance.class == Class
      permissionable_class_or_instance.included_modules.include? Sanction::Permissionable
    else
      permissionable_class_or_instance.class.included_modules.include? Sanction::Permissionable
    end
    
  end
  
  # Used in the UI to display the name of a principal or permissionable instance
  def self.eval_name(principal_or_permissionable_instance)
    if self.is_valid_principal? principal_or_permissionable_instance
      the_method = self.principal_to_s_methods[principal_or_permissionable_instance.class.to_s]
    elsif self.is_valid_permissionable? principal_or_permissionable_instance
      the_method = self.permissionable_to_s_methods[principal_or_permissionable_instance.class.to_s]
    else
      raise "Sanction Ui Error: #{principal_or_permissionable_instance} id=#{principal_or_permissionable_instance.id} is not a configured permissionable or principal in sanction.rb"
    end
    if the_method.blank?
      the_method = "id"
      RAILS_DEFAULT_LOGGER.warn "Sanction Ui Warning: No defined \"to_s\"ish method for #{principal_or_permissionable_instance}"
    end
    eval_string = "principal_or_permissionable_instance.#{the_method}"
    begin
      return eval(eval_string)
    rescue Exception => e
      return "Sanction Ui Error: Invalid method: #{eval_string}, exception = #{e.inspect}"
    end
  end
end
unless ApplicationController.instance_methods.include? "current_principal"
  raise "Sanction Ui Error: 
  
    Your ApplicationController does not implement :current_principal, it must.
    
    If you already have a different named method that does this, just make an alias for current_principal
    
    Also--this object, whatever it is, must be configured in the sanction.rb initializer as a Principal, go add it.  
  "
end