class Merchants::DiscountsController < ApplicationController
  before_action :require_merchant

  def index
    @discounts = Discount.where(user: current_user)

  end

end
