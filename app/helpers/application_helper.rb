module ApplicationHelper
  def discount_to_words(discount)
    if discount.discount_type == 'dollar'
      "$#{discount.discount_amount} off an order of $#{discount.quantity_for_discount} or more"
    elsif discount.discount_type == 'percentage'
      "#{discount.discount_amount}% off when you buy #{discount.quantity_for_discount} or more items"
    end
  end
end
