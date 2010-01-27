# This is the top of the inheritance hierarchy for sanction ui
# It only contains helper methods you might want to override in
# you app
# NOTE:
class SanctionUi::TopLevelController < ApplicationController
  layout 'sanction_ui'

  # PROTECTED METHODS (OVERRIDE IF NEEDED)
  protected
  
  # Central point through which all sanction_ui auth checks in controllers and views
  # go through 
  def action_allowed?(access_check_method_name, options={})
    unless respond_to? SanctionUi.current_user_method
      raise "Error: Your application controller does not implement :#{SanctionUi.current_user_method}, it must."
    end
    principal_instance = current_user_principal_instance(access_check_method_name, options)
    unless principal_instance.class.included_modules.include? Sanction::Principal
      raise "Your #{SanctionUi.current_user_method} method must yield an instance that is a configured principal of sanction
             go add it in config/initializers/sanction.rb
       "
    end
    return perform_access_control_check_on_user(principal_instance, access_check_method_name, options)
  end
  helper_method :action_allowed?

  # 
  def current_user_principal_instance(access_check_method_name, options)
    send(SanctionUi.current_user_method)
  end
  helper_method :current_user_principal_instance
  
  # Actual check for particular permission
  #
  def perform_access_control_check_on_user(principal_instance, access_check_method_name, options={})
    principal_instance.has?(access_check_method_name)
  end
  
  #########################################
  # PRIVATE INTERNAL HELPER METHODS
  private
  def sui_label(name)
    if SanctionUi.labels[name.to_sym].blank?
      "stub"
    else
      SanctionUi.labels[name.to_sym]
    end
  end
  helper_method :sui_label
  
  
  def role_instances_for_global_role(roles, role_definition)
    roles.find_all {|r| r.name.to_sym == role_definition.name}
  end
  helper_method :role_instances_for_global_role
  
  def role_instances_for_non_global_role_and_principal(roles, role_definition, principal_class)
    roles.find_all {|r|
      r.name.to_sym == role_definition.name && 
      r.principal_type.to_s == principal_class.to_s 
    }.sort {|a,b| "#{a.principal_type} #{a.permissionable_type}" <=> "#{b.principal_type} #{b.permissionable_type}"}
  end
  helper_method :role_instances_for_non_global_role_and_principal
end