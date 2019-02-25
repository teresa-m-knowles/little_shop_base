class Discount < ApplicationRecord
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


end
