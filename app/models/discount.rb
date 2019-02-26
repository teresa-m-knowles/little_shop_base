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


  def self.get_dollar_discount(merchant_id, amount)
    Discount.where(user_id: merchant_id)
            .where(discount_type: 0)
            .where('discounts.quantity_for_discount <= ?', amount)
            .order('discount_amount desc')
            .first
  end

  def self.get_percentage_discount(item, quantity_of_items)
    Discount.where(user_id: item.merchant_id)
            .where(discount_type: 1)
            .where('discounts.quantity_for_discount <= ?', quantity_of_items)
            .order('discount_amount desc')
            .first
  end
end
