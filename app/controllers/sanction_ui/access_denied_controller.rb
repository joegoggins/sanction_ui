# A controller used to redirect users to when they do not have access to a particular action
#
class SanctionUi::AccessDeniedController < SanctionUi::TopLevelController
  # Skip all authorization requirements here
  skip_filter filter_chain
  layout false
  
  def show
    # If this flash is not set, the show page doesn't describe the reason for denial
    # This happens when crawlers stumble on this or if the user refreshes
    @sui_flash_set = flash[:sui_denied_role_def_or_perm_name].blank? ? false : true
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
    unless flash[:sui_denied_over_instance].blank?
      @over_instance = flash[:sui_denied_over_instance]
    end
  end
end