# This is the top of the inheritance hierarchy for sanction ui
# It only contains helper methods you might want to override in
# you app
# NOTE:
class SanctionUi::TopLevelController < ApplicationController
  layout 'sanction_ui'

  @@current_principal_checked = false

  # PROTECTED METHODS (OVERRIDE IF NEEDED)
  protected
  
  # Central point through which all sanction_ui auth checks in controllers and views
  # go through 
  def action_allowed?(sanction_permission, options={})
    if !options[:role].blank?
      action_allowed_for_role?(sanction_permission, options[:role])    
    elsif !options[:role_definition].blank?
      action_allowed_for_role_definition?(sanction_permission, options[:role_definition])    
    else
      perform_access_control_check(sanction_permission)
    end
  end
  helper_method :action_allowed?

  # Override in SanctionUi::AuthController if needed
  def action_allowed_for_role?(sanction_permission, role)
    perform_access_control_check(sanction_permission)
  end
  
  # Override in SanctionUi::AuthController if needed
  def action_allowed_for_role_definition?(sanction_permission, role_definition)
    perform_access_control_check(sanction_permission)
  end  
    
  # Actual check for particular permission without regard to any permissionable
  #
  def perform_access_control_check(sanction_permission)
    if current_principal.blank?
      false # Probably un-authenticated
    else
      begin
        current_principal.has?(sanction_permission)
      rescue NameError => e
        raise "Sanction Ui Error: current_principal method must return an object that responds to .has?
               This could be because you haven't added this returned object to the
               sanction principals in config/initializers/sanction.rb.
        "
      end
    end
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