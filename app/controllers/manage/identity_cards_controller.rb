class Manage::IdentityCardsController < Manage::BaseController
  include ApplicationHelper
  before_action :user_manage_permission
  def index
    @identity_cards = IdentityCard.all
  end

  def new
  end

  def create
    @identity_card = IdentityCard.new(identity_card_params)
    if @identity_card.save
      redirect_to manage_identity_cards_path
    else
      respond_to json: {}, status: 422
    end
  end


  private
    def identity_card_params
      params.require(:identity_card).permit(:name)
    end
end