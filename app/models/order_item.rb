class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }


  def subtotal
    quantity * price
  end

  def inventory_available
    item.inventory >= quantity
  end

  def fulfill
    if item.inventory >= quantity && !self.fulfilled
      item.inventory -= quantity
      self.fulfilled = true
      item.save
      save
    end
  end

  # def self.combined_not_enough_stock(merchant_id)
  #     self.joins(orders: :items)
  #         .where(fulfilled: false, items: {merchant_id: merchant_id} )
  #         .group('items.id').having('quantity > items.inventory')
  # end
end
