# A controller used to redirect users to when they do not have access to a particular action
#
class SanctionUi::AccessDeniedController < SanctionUi::TopLevelController
  # Skip all authorization requirements here
  skip_filter filter_chain
  layout false
  
  def show
    @role_definitions = Sanction::Role::Definition.all.find_all do |x| 
      x.name == params[:role_def_or_perm_name].to_sym ||
      x.permissions.include?(params[:role_def_or_perm_name].to_sym)
    end
  end
end