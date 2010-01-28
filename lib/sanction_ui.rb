module SanctionUi
  @@plugin_base_path = "vendor/plugins/sanction_ui"
  mattr_accessor :plugin_base_path

  @@asset_override_base_path = "app/views/sanction_ui/assets"
  mattr_accessor :asset_override_base_path
  
  @@route_url_prefix = '/permissions'
  mattr_accessor :route_url_prefix
  
  # The method that will be called to get a Principal object to check
  # if they can revoke, grant, authorize, or unauthorize sanction roles
  # 
  @@current_principal_method = :current_principal
  mattr_accessor :current_principal_method
  
  # Method called to render what the instance is in the UI
  #
  @@principals_to_s_method = :name
  mattr_accessor :principals_to_s_method 
  @@permissionables_to_s_method = :name
  mattr_accessor :permissionables_to_s_method
  
  # Used for all strings via sui_label method in sanction UI
  #
  @@labels = {:can_add_role => "add",
     :can_remove_role => "remove", 
     :can_describe_role => "describe",
     :confirm_remove_role => 'You sure?',
     :over => 'over',
     :principal_type => 'Principal Type: ',
     :principal_id => "Principal ID: ", 
     :permissionable_type => 'Permissionable Type: ',
     :permissionable_id => "Permissionable ID: ",
     :permissionable_all => "Check to add role over all instances of this type",
     :access_denied => 'Access Denied',
     # What gets shown in the title of pages
     :sanction_ui_title => 'Permissions Management System'
  }
  mattr_accessor :labels
  
  # To override one label
  def self.set_label(key,value)
    if labels[key.to_sym].blank?
      raise "Invalid label key"
    else
      self.labels[key] = value
    end
  end
  
  # Set to false if you want your access denied page to
  # say nothing to users about why they were denied access
  # Will use @role_definition.purpose for the string to describe.
  #
  @@describe_on_deny = true
  mattr_accessor :describe_on_deny
    
  # Will display on access denied form if both are not blank
  #
  @@denied_contact_label = ""
  mattr_accessor :denied_contact_label
  @@denied_contact_email = ""
  mattr_accessor :denied_contact_email
  
end
unless SanctionUi::ApplicationController.instance_methods.include? "current_principal"
  raise "Sanction Ui Error: 
  
    Your ApplicationController does not implement :current_principal, it must.
    
    If you already have a different named method that does this, just make an alias for current_principal
    
    Also--this object, whatever it is, must be configured in the sanction.rb initializer as a Principal, go add it.  
  "
end