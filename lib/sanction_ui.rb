module SanctionUi
  @@plugin_base_path = "vendor/plugins/sanction_ui"
  mattr_accessor :plugin_base_path

  @@asset_override_base_path = "app/views/sanction_ui_asset_overrides"
  mattr_accessor :asset_override_base_path
  
  @@route_url_prefix = '/permissions'
  mattr_accessor :route_url_prefix
  
  # The method that will be called to get a Principal object to check
  # if they can revoke, grant, authorize, or unauthorize sanction roles
  # 
  @@current_user_method = :current_user
  mattr_accessor :current_user_method
end