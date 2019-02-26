require 'rails_helper'

RSpec.describe Discount do
  describe 'validations' do
    it {should validate_presence_of :discount_type}

    it {should validate_presence_of :discount_amount}
    it { should validate_numericality_of(:discount_amount).is_greater_than(0) }
    it { should validate_numericality_of(:discount_amount).only_integer }


    it {should validate_presence_of :quantity_for_discount}
    it { should validate_numericality_of(:quantity_for_discount).is_greater_than(0) }
    it { should validate_numericality_of(:quantity_for_discount).only_integer }


  end

  describe 'relationships' do
    it {should belong_to :user}
  end

  describe 'Class methods' do
    it '.get_dollar_discount' do
      merchant = create(:merchant)
      item_1 = create(:item, user: merchant, name: "Atari", active: true, price: 5, inventory: 20)
      item_2 = create(:item, user: merchant, name: "Super Nintendo", active: true, price: 20, inventory: 20)

      #$10 off an order of $70 or more
      discount = merchant.discounts.create(discount_type: 0, discount_amount: 10, quantity_for_discount: 70)
      #$3 off an order of $5 or more
      discount_2 = merchant.discounts.create(discount_type: 0, discount_amount: 3, quantity_for_discount: 5)

      expect(Discount.get_dollar_discount(merchant.id,70)).to eq(discount)
      expect(Discount.get_dollar_discount(merchant.id,69)).to eq(discount_2)

    end

    it '.get_percentage_discount' do
      merchant = create(:merchant)
      item = create(:item, user: merchant, name: "Atari", active: true, price: 5, inventory: 20)

      #50% off 100 or more items
      discount = merchant.discounts.create(discount_type: 1, discount_amount: 50, quantity_for_discount: 100)
      #20% off 30 or more items
      discount_2 = merchant.discounts.create(discount_type: 1, discount_amount: 20, quantity_for_discount: 30)

      expect(Discount.get_percentage_discount(item, 101)).to eq(discount)
      expect(Discount.get_percentage_discount(item,29)).to eq(nil)
      expect(Discount.get_percentage_discount(item,30)).to eq(discount_2)

    end
  end
end
