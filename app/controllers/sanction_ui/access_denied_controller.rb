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
    
    unless params[:over_type].blank?
      begin
        @over_type = params[:over_type].constantize
      rescue NameError => e
        render :text => "Invalid over type" and return
      end
    end
    
    # Route is set up like :over_type/*over_id", hence the arrayness below
    unless params[:over_id].blank?
      @over_id = params[:over_id].first
    end
    
  end
end