class Discount < ApplicationRecord
  belongs_to :user, foreign_key: 'merchant_id'
  validates_presence_of :type

  validates :item_quantity_for_discount, presence: true, numericality: {
    only_integer: true,
    greater_than: 0}

    validates :discount_amount, presence: true, numericality: {
      only_integer: true,
      greater_than: 0}


end
