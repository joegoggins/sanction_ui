# A controller used to redirect users to when they do not have access to a particular action
#
class SanctionUi::AccessDeniedController < SanctionUi::TopLevelController
  # Skip all authorization requirements here
  skip_filter filter_chain
  layout false
  
  def show
    @role_definitions = Sanction::Role::Definition.all.find_all do |x| 
      x.name == flash[:sui_denied_role_def_or_perm_name] ||
      x.permissions.include?(flash[:sui_denied_role_def_or_perm_name])
    end
    
    unless flash[:sui_denied_over_type].blank?
      if flash[:sui_denied_over_type].class == Class
        @over_type = flash[:sui_denied_over_type]
      else
        render :text => "Invalid over type #{flash[:sui_denied_over_type]}" and return
      end
    end
    
    # Route is set up like :over_type/*over_id", hence the arrayness below
    unless flash[:sui_denied_over_id].blank?
      @over_id = flash[:sui_denied_over_id]
    end
  end
end