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

  def get_percentage_discounts
    item_and_percentage = Hash.new(0)
    @contents.each do |item_id, quantity|
      item = Item.find(item_id.to_i)
      item_and_percentage[item] = Discount.get_percentage_discount(item, quantity)
    end
    return item_and_percentage

  end

  def subtotal(item_id)
    item = Item.find(item_id)
    total = 0
    if get_percentage_discounts[item]
      discount = get_percentage_discounts[item].discount_amount.to_f/100
      without_discount = item.price * count_of(item_id)
      discount_amount = without_discount * discount
      total = without_discount - discount_amount
    else
      total = item.price * count_of(item_id)
    end
    return total
  end




  def grand_total
    total = @contents.keys.map do |item_id|
      subtotal(item_id)
    end.sum

    if get_dollar_discounts
      total -= get_dollar_discounts.discount_amount
    end
    return total
  end
end
