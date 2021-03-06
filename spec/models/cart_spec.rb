require 'rails_helper'

RSpec.describe Cart do
  it '.total_count' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })
    expect(cart.total_item_count).to eq(5)
  end

  it '.items' do
    item_1, item_2 = create_list(:item, 2)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)

    expect(cart.items).to eq([item_1, item_2])
  end

  it '.count_of' do
    cart = Cart.new({})
    expect(cart.count_of(5)).to eq(0)

    cart = Cart.new({
      '2' => 3
    })
    expect(cart.count_of(2)).to eq(3)
  end

  it '.add_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.add_item(1)
    cart.add_item(2)
    cart.add_item(3)

    expect(cart.contents).to eq({
      '1' => 3,
      '2' => 4,
      '3' => 1
      })
  end

  it '.remove_all_of_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.remove_all_of_item(1)

    expect(cart.contents).to eq({
      '2' => 3
    })
  end

  it '.subtract_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.subtract_item(1)
    cart.subtract_item(1)
    cart.subtract_item(2)

    expect(cart.contents).to eq({
      '2' => 2
      })
  end

  it '.subtotal_without_discount' do
    item_1 = create(:item)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)

    expect(cart.subtotal_without_discount(item_1.id)).to eq(item_1.price * cart.total_item_count)
  end

  it '.grand_total' do
    merchant_1 = create(:merchant)

    item_1 = create(:item, user: merchant_1, price: 25)
    item_2 = create(:item, user: merchant_1, price: 100)
    # 10% off orders with 5 or more of one item
    merchant_1.discounts.create(discount_type: 1, quantity_for_discount: 5, discount_amount: 10)

    cart = Cart.new({})
    # Cart has $125 of item 1
    #Subtotal without discount is $125
    #Subtotal with discount is  112.50
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)

    cart.add_item(item_2.id)
    cart.add_item(item_2.id)

    expect(cart.grand_total).to eq(312.50)
  end

  describe 'grand total only substracts dollar discount from one item' do
    it 'only substracts the dollar discount once' do

      merchant_1 = create(:merchant)

      item_1 = create(:item, user: merchant_1, price: 25)
      item_2 = create(:item, user: merchant_1, price: 100)

      # $20 off orders with $150 or more
      merchant_1.discounts.create(discount_type: 0, quantity_for_discount: 150, discount_amount: 20)

      cart = Cart.new({})

      #Adding $125 worth of item_1
      cart.add_item(item_1.id)
      cart.add_item(item_1.id)
      cart.add_item(item_1.id)
      cart.add_item(item_1.id)
      cart.add_item(item_1.id)

      #Adds $200 to cart of item_2
      cart.add_item(item_2.id)
      cart.add_item(item_2.id)

      #Cart total without discount = $325
      #Discount is $20 off
      #Grand total is $305

      expect(cart.grand_total).to eq(305)
    end
  end

  it '.all_items_not_array' do
    item_1, item_2, item_3 = create_list(:item, 3)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)

    expect(cart.all_items_not_array).to eq([item_1, item_2])
    expect(cart.all_items_not_array.class).to_not eq(Array)
  end


  it '.count_of_items_from_same_merchant' do
    merchant = create(:merchant)
    other_merchant = create(:merchant)
    item_1 = create(:item, merchant_id: merchant.id)
    item_2 = create(:item, merchant_id: merchant.id)
    item_3 = create(:item, merchant_id: other_merchant.id)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)
    cart.add_item(item_3.id)

    expect(cart.count_of_items_from_same_merchant(item_1)).to eq(2)
    expect(cart.count_of_items_from_same_merchant(item_2)).to eq(2)
    expect(cart.count_of_items_from_same_merchant(item_3)).to eq(1)
  end

  it '.subtotal_from_same_merchant' do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)
    item_1 = create(:item, price: 7, user: merchant_1)
    item_2 = create(:item, price: 10, user: merchant_1)
    item_3 = create(:item, price: 15, user: merchant_2)
    item_4 = create(:item, price: 20, user: merchant_2)

    cart = Cart.new({})
    #Merchant 1 subtotal: $24
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)

    #Merchant 2 subtotal: $55
    cart.add_item(item_3.id)
    cart.add_item(item_4.id)
    cart.add_item(item_4.id)

    expect(cart.subtotal_from_same_merchant(item_1.id)).to eq(24)
    expect(cart.subtotal_from_same_merchant(item_2.id)).to eq(24)
    expect(cart.subtotal_from_same_merchant(item_3.id)).to eq(55)
    expect(cart.subtotal_from_same_merchant(item_4.id)).to eq(55)



  end

  describe '.find_discount with all dollar discounts' do
    it '.find_discount' do
      merchant_1 = create(:merchant)
      merchant_2 = create(:merchant)
      merchant_3 = create(:merchant)

      item_1 = create(:item, user: merchant_1, price: 50)
      item_2 = create(:item, user: merchant_2, price: 75)
      item_3 = create(:item, user: merchant_3)

      discount_1 = merchant_1.discounts.create(discount_type: 0, quantity_for_discount: 200, discount_amount: 100)

      discount_2 = merchant_2.discounts.create(discount_type: 0, quantity_for_discount: 140, discount_amount: 60)

      cart = Cart.new({})
      cart.add_item(item_1.id)
      cart.add_item(item_1.id)
      cart.add_item(item_1.id)
      cart.add_item(item_1.id)

      cart.add_item(item_2.id)
      cart.add_item(item_2.id)


      cart.add_item(item_3.id)
      cart.add_item(item_3.id)

      expect(cart.find_discount(item_1)).to eq(discount_1)
      expect(cart.find_discount(item_2)).to eq(discount_2)

      #since merchant 3 has no discounts:
      expect(cart.find_discount(item_3)).to eq(nil)


    end
  describe '.find_discount with percentage' do
    it '.find_discount' do
      merchant_1 = create(:merchant)

      item_1 = create(:item, user: merchant_1, price: 50)
      # 10% off orders with 5 or more of one item
      discount_1 = merchant_1.discounts.create(discount_type: 1, quantity_for_discount: 5, discount_amount: 10)

      cart = Cart.new({})
      cart.add_item(item_1.id)
      cart.add_item(item_1.id)
      cart.add_item(item_1.id)
      cart.add_item(item_1.id)
      cart.add_item(item_1.id)

      expect(cart.find_discount(item_1)).to eq(discount_1)

    end

  end


  it '.calculate_discount' do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)

    item_1 = create(:item, user: merchant_1, price: 27)
    item_2 = create(:item, user: merchant_2, price: 10)

    # 10% off orders with 5 or more of one item
    merchant_1.discounts.create!(discount_type: 1, quantity_for_discount: 5, discount_amount: 10)
    # $5 off orders with $20 or more
    merchant_2.discounts.create!(discount_type: 0, quantity_for_discount: 20, discount_amount: 5)

    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)

    cart.add_item(item_2.id)
    cart.add_item(item_2.id)

    expect(cart.calculate_discount(item_1)).to eq(13.50)
    expect(cart.calculate_discount(item_2)).to eq(5)
  end

  it '.subtotal_with_discount' do
    merchant_1 = create(:merchant)

    item_1 = create(:item, user: merchant_1, price: 25)
    item_2 = create(:item, user: merchant_1, price: 100)
    # 10% off orders with 5 or more of one item
    merchant_1.discounts.create(discount_type: 1, quantity_for_discount: 5, discount_amount: 10)

    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)

    cart.add_item(item_2.id)
    cart.add_item(item_2.id)

    expect(cart.subtotal_with_discount(item_1.id)).to eq(112.50)
    expect(cart.subtotal_with_discount(item_2.id)).to eq(200)

  end
end

end
