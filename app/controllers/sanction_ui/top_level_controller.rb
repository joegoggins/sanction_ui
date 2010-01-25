# This is the top of the inheritance hierarchy for sanction ui
# It only contains helper methods you might want to override in
# you app
class SanctionUi::TopLevelController < ApplicationController
  layout 'sanction_ui'
  # Essentially an auth centralization method that precedes delegation to sanction
  # to ask various questions about whether the various actions associated with sanction ui can happen for a given user
  #
  #
=begin

TODO: grep and replace can_TODO_sanction_ui? instances


Here is the map of how it should be
main/index => can_view_sanction_ui_index?
main/describe => can_view_sanction_ui_describe?

roles/index => can_view_sanction_ui_roles?
roles/new? + roles/create
  => 
can_add_principal
roles/destroy => can_
=end
  def action_allowed?(access_check_method_name, options={})
    return true
    unless respond_to? SanctionUi.current_user_method
      raise "Error: Your application controller does not implement :#{SanctionUi.current_user_method}, it must."
    end
    sanction_ui_user = send(SanctionUi.current_user_method)
    
    unless sanction_ui_user.class.included_modules.include? Sanction::Principal
      raise "Your #{SanctionUi.current_user_method} method must yield an instance that is a configured principal of sanction
             go add it in config/initializers/sanction.rb
       "
    end

    return sanction_ui_user.has?(access_check_method_name)
  end
  helper_method :action_allowed?
=begin
  if respond_to? SanctionUi.current_user_method
    unless current_user.class.included_modules.include? Sanction::Principal
      raise "TODO: Go add #{current_user.class} to config.principals in the sanction initializers"
    end
  else
    raise "TODO: TO use sanction_ui, you must define some method in your controller that yields a valid sanction principal instance to do auth checks
           Currently, SanctionUi is configured to call #{SanctionUi.current_user_method}, feel free to specify a different method in you
           environment.rb by setting SanctionUi.current_user_method=:your_method
         "
  end  
  

  # OVERRIDABLE CONTROL CHECKS IN THE UI
  def can_add_principal_for_global_role?(role_definition) 
    true
  end
  helper_method :can_add_principal_for_global_role?
  
  def can_remove_principal_for_global_role?(role_definition) 
    true
  end
  helper_method :can_remove_principal_for_global_role?
=end

  def labels
    {:add_principal_for_global_role => "+",
     :stub => 'stub',
     :over => '<em>over</em>',
     :remove_principal => "-", # Removes from all roles for a given role def
     :remove_role => "-" # removes just the most granular role
     }
  end
  helper_method :labels
  
  
  # INTERNAL HELPER METHODS
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