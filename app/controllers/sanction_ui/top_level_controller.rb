# This is the top of the inheritance hierarchy for sanction ui
# It only contains helper methods you might want to override in
# you app
class SanctionUi::TopLevelController < ApplicationController
  # ACCESS CONTROL CHECKS IN THE UI
  def can_add_principal_for_global_role?(role_definition) 
    true
  end
  helper_method :can_add_principal_for_global_role?
  
  def can_remove_principal_for_global_role?(role_definition) 
    true
  end
  helper_method :can_remove_principal_for_global_role?
  
  def labels
    {:add_principal_for_global_role => "add",
     :stub => 'stub'
     }
  end
  helper_method :labels
  
  def role_instances_for_global_role(roles, role_definition)
    roles.find_all {|r| r.name.to_sym == role_definition.name}
  end
  helper_method :role_instances_for_global_role
  
  
  def role_instances_for_non_global_role_and_principal(roles, role_definition, principal_class)
    roles.find_all {|r|
      r.name.to_sym == role_definition.name && 
      r.principal_type.to_s == principal_class.to_s 
    }
  end
  helper_method :role_instances_for_non_global_role_and_principal
end