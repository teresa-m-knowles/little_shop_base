class Merchants::DiscountsController < ApplicationController
  before_action :require_merchant

  def index
    @discounts = Discount.where(user: current_user)
  end

  def show
    @discount = Discount.find(params[:id])

  end

  def new
    @discount = Discount.new
    @form_path = [:dashboard, @discount]

  end

  def create
    merchant = current_user
    @discount = merchant.discounts.new(discount_params)
    @form_path = [:dashboard, @discount]

      if @discount.save
        flash[:success] = "New discount created"
        redirect_to dashboard_discounts_path
      else
        render :new
      end

  end

  def edit
    @discount = Discount.find(params[:id])
    @form_path = [:dashboard, @discount]
  end

  def update
    @discount = Discount.find(params[:id])
    if @discount.update(discount_params)
      flash[:success] = "You have updated the discount"
      redirect_to dashboard_discount_path(@discount)
    else
      @form_path = [:dashboard, @discount]
      render :edit
    end

  end

  private

  def discount_params
    params.require(:discount).permit(:discount_type, :discount_amount, :quantity_for_discount, :user)
  end

end
