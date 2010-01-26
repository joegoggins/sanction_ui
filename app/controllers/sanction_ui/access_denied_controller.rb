# A controller used to redirect users to when they do not have access to a particular action
#
class SanctionUi::AccessDeniedController < SanctionUi::TopLevelController
  def show
    @role_definition = params[:role_definition]
  end
end