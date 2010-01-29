# You can override methods defined in SanctionUi::TopLevelController here.
# Via before_filter's you can also augment the behavior of child classes
#
# Inheritance Hierachy:
# ApplicationController (Rails)
#   SanctionUi::TopLevelController (Plugin)
#     SanctionUi::AccessDeniedController (Plugin)
#     SanctionUi::AssetController (Plugin)
#     SanctionUi::AuthController (App)      YOU ARE HERE, feel free to OVERRIDE stuff in TopLevelController
#       SanctionUi::MainController (Plugin)
#       SanctionUi::RolesController (Plugin)
#
class SanctionUi::AuthController < SanctionUi::TopLevelController
  layout 'sanction_ui'
  
  # OVERRIDE IF YOU NEED SUPER GRANULAR STUFF FOR A PARTICULAR ROLE
  # For example: always return false for sanction_permission=:can_add_role role.principal == your boss
  #
  #def action_allowed_for_role?(sanction_permission, role)
  #  (current_principal.has? sanction_permission) && 
  #  (current_principal.SOME_OTHER_SPECIAL_CHECK)
  #end

  # OVERRIDE IF YOU WANT TO DELEGATE MANAGEMENT OF SANCTION ROLE DEFINITIONS TO SPECIFIC PEOPLE
  # 
  #def action_allowed_for_role_definition?(sanction_permission, role_definition)
  #  perform_access_control_check(sanction_permission)
  #end
  
  
  # If you want to do some special stuff to override or load some additional data
  # to be rendered in overridden Sanction UI partials, you can do this via before_filters like follows:
  # Note: use one of various flavors of the action_allowed* methods to do access control, not
  # before filters
  #
  #  before_filter :only => ... do |controller|
  #    if controller.class == SanctionUi::RolesController &&
  #        controller.action_name == 'new'
  #      @your_special_fresh_data = Special.find bla bla bla
  #    end
  #  end
end