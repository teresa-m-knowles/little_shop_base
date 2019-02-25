class Discount < ApplicationRecord
  include ActiveModel::Validations
  validates_with DiscountValidator

  enum discount_type: [:dollar, :percentage]

  belongs_to :user
  validates_presence_of :discount_type
  # validates_inclusion_of :discount_type, :in => [:dollar, :percentage]

  validates :quantity_for_discount, presence: true, numericality: {
    only_integer: true,
    greater_than: 0}

    validates :discount_amount, presence: true, numericality: {
      only_integer: true,
      greater_than: 0}

  #gets a @cart.contents
  #groups items by merchant
  #adds the subtotal for those OrderItems
  #we have a hash {merchant_1 => 55},
  #                {merchant_2 => 30}
  #if merchant_1 has a discount of $10 off orders of $50 or more
  #this method should return the discount that matches
  def self.get_dollar_discount(merchant_id, quantity)
    Discount.where(user_id: merchant_id)
            .where(discount_type: 0)
            .where('discounts.quantity_for_discount <= ?', quantity)
            .order('discount_amount desc')
            .first
  end
end
