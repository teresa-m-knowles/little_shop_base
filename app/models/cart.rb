class Cart
  attr_reader :contents

  def initialize(initial_contents)
    @contents = initial_contents || Hash.new(0)
  end

  def items
    @contents.keys.map do |item_id|
      Item.includes(:user).find(item_id)
    end
  end

  def total_item_count
    @contents.values.sum
  end

  def count_of(item_id)
    @contents[item_id.to_s].to_i
  end

  def add_item(item_id)
    @contents[item_id.to_s] ||= 0
    @contents[item_id.to_s] += 1
  end

  def subtract_item(item_id, count=1)
    @contents[item_id.to_s] -= count
    @contents.delete(item_id.to_s) if @contents[item_id.to_s] == 0
  end

  def remove_all_of_item(item_id)
    subtract_item(item_id, count_of(item_id))
  end

  #group all items by merchant id and add their subtotals
  def get_dollar_discounts
    merchant_id_subtotal = Hash.new(0)

    @contents.keys.each do |item_id|
      item = Item.find(item_id.to_i)
      merchant_id_subtotal[item.merchant_id] += subtotal(item_id)
    end

    merchant_id_subtotal.each do |merchant_id, quantity|
      merchant = User.find(merchant_id)
      if !merchant.discounts.empty?
        discount = Discount.get_dollar_discount(merchant_id, quantity)
      else
        return nil
      end
      return discount
    end





  end

  def subtotal(item_id)
    item = Item.find(item_id)

    # if merchant.discounts.empty?
      total = item.price * count_of(item_id)
    # else
    #   type = merchant.discounts.pluck(:discount_type).first
    #   if type == 'dollar'
    #     total = item.price * count_of(item_id)
    #     discount = Discount.dollar_check(item, total)
    #     #should return nil if no dollar discount applies or the biggest dollar discount possible if it does
    #     total -= discount.discount_amount
    #
    #   elsif type == 'percentage'
    #     discount = Discount.percentage_check(item, count_of(item))
    #     #should return nil if no % discount applies or the biggest % discount possible if it does
    #     total = item.price * count_of(item_id)
    #     total_discount = (discount.discount_amount/100) * total
    #     total -= total_discount
    #   end
    # end
   return total
  end




  def grand_total
    total = @contents.keys.map do |item_id|
      subtotal(item_id)
    end.sum

    if get_dollar_discounts
      total -= get_dollar_discounts.discount_amount
    else
      total
    end
    return total
  end
end
