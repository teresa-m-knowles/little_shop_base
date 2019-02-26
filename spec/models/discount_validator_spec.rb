require 'rails_helper'

RSpec.describe DiscountValidator do
  context 'Validates discounts when they are created' do
    describe 'when the discount type matches all other discounts types' do
      it 'can create a new discount' do
        merchant = create(:merchant)
        discount_1 = merchant.discounts.create(discount_type: 0, quantity_for_discount: 5, discount_amount: 10)
        discount_2 = merchant.discounts.create(discount_type: 0, quantity_for_discount: 5, discount_amount: 10)

        expect(discount_2.errors.messages).to eq({})
      end
    end

    describe 'when the discount type does not match all other discounts types' do
      it 'cannot create a new discount' do
        merchant = create(:merchant)
        discount_1 = merchant.discounts.create(discount_type: 0, quantity_for_discount: 5, discount_amount: 10)
        discount_2 = merchant.discounts.create(discount_type: 1, quantity_for_discount: 5, discount_amount: 10)

        expect(discount_2.errors.messages.values.flatten).to include("All of your discounts need to be of the same type. If you wish to change the type of your discounts, please delete all of your discounts first.")
      end
    end

    describe 'different merchants can have different discount types' do
      it 'can create a different discount type for a different merchant' do
        merchant_1 = create(:merchant)
        merchant_2 = create(:merchant)

        discount_1 = merchant_1.discounts.create(discount_type: 0, quantity_for_discount: 5, discount_amount: 10)
        discount_2 = merchant_2.discounts.create(discount_type: 1, quantity_for_discount: 5, discount_amount: 10)

        expect(discount_2.errors.messages).to eq({})

      end

    end
  end
end
