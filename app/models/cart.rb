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

  def all_items_not_array
    items_ids = @contents.keys.map(&:to_i)
    Item.where(id: items_ids)
  end

  def count_of_items_from_same_merchant(item)
    all_items_not_array.where(merchant_id: item.merchant_id).count
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

  def subtotal_with_discount(item_id)
    item = Item.find(item_id)
    subtotal_without_discount(item_id) - calculate_discount(item)
  end

  def subtotal_without_discount(item_id)
    item = Item.find(item_id)
    item.price * count_of(item_id)
  end

  def subtotal_from_same_merchant(item_id)
    given_item = Item.find(item_id)
    items_from_same_merchant = items.select do |item|
        item.merchant_id == given_item.merchant_id
      end
    items_from_same_merchant.sum do |item|
      subtotal_without_discount(item.id)
    end
  end

  def calculate_discount(item)
    discount = find_discount(item)
    if discount ##if find_discount did not return nil, calculate the amount
      if discount.discount_type == 'dollar'
        return (discount.discount_amount / count_of_items_from_same_merchant(item))
      elsif discount.discount_type =='percentage'
        percentage_off = discount.discount_amount.to_f/100
        return subtotal_without_discount(item.id) * percentage_off
      end
    else #if there is no discount, return 0
      return 0
    end
  end

  def find_discount(item)
    unless item.user.discounts.empty?
      if Discount.where(user: item.user, discount_type: 'dollar').exists?
        return Discount.get_dollar_discount(item.merchant_id, subtotal_from_same_merchant(item.id))
      elsif Discount.where(user: item.user, discount_type: 'percentage').exists?
        return Discount.get_percentage_discount(item, count_of(item.id))
      end
    end
  end


  def grand_total
    @contents.keys.map do |item_id|
      subtotal_with_discount(item_id)
    end.sum

  end
end
