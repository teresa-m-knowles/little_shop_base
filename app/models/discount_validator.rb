class DiscountValidator < ActiveModel::Validator
  def validate(discount)
    saved_discount = Discount.first
    if Discount.all.count >= 1
      unless discount.discount_type == saved_discount.discount_type
        discount.errors[:discount_type] << "All of your discounts need to be of the same type.
        If you wish to change the type of your discounts, please delete all of your discounts first."
      end
    end

  end
end
