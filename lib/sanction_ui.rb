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
  @@current_user_method = :current_user
  mattr_accessor :current_user_method
  
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
     :permissionable_all => "Check to add role over all instances of this type"
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
  # say nothing to users that have some other permission
  # other than the one they were denied for
  #
  @@describe_role_to_known_users_on_access_denied = true
  mattr_accessor :describe_role_to_known_users_on_access_denied
end