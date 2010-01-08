class SanctionUi::RolesController < SanctionUi::AuthController
  def index
  end

  def new
    if params[:global].blank?
    else
      @principles = Sanction.principals
    end
  end

  def create
  end

  def destroy
  end
end
