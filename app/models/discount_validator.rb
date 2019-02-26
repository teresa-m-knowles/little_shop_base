class DiscountValidator < ActiveModel::Validator
  def validate(discount)
    existing_discount = Discount.find_by(user_id: discount.user_id)

    if existing_discount
      unless existing_discount.discount_type == discount.discount_type
        discount.errors[:discount_type] << "All of your discounts need to be of the same type. If you wish to change the type of your discounts, please delete all of your discounts first."
      end
    end

  end
end
