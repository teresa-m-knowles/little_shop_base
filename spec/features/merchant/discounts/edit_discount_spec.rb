require 'rails_helper'

RSpec.describe 'As a merchant', type: :feature do
  describe 'I can edit a discount' do
    before :each do
      @merchant = create(:merchant)
      @discount_1 = @merchant.discounts.create!(discount_type: 0, discount_amount: 50, quantity_for_discount: 100)
    end
    it 'it can edit a discount quantity or amount and redirect me to show page' do

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit edit_dashboard_discount_path(@discount_1)

      fill_in "Discount amount", with: 150
      fill_in "Quantity for discount", with: 100
      click_on "Update Discount"

      expect(page).to have_content("You have updated the discount")
      expect(current_path).to eq(dashboard_discount_path(@discount_1))
      expect(page).to have_content(@discount_1.discount_type.capitalize)
      expect(page).to have_content("Quantity for discount: 100")
      expect(page).to have_content("Discount amount: 150")

    end

    context 'if I have other discounts in the system' do
      it 'the discount type has to match all other discounts' do
        discount_2 = @merchant.discounts.create!(discount_type: 0, discount_amount: 23, quantity_for_discount: 100)
        #can't edit this discount to a percentage type
        #since I have one other discount in the system that's a dollar type
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit edit_dashboard_discount_path(discount_2)

        choose(option: 'percentage')
        click_on "Update Discount"

        expect(page).to_not have_content("You have updated the discount")
        expect(page).to have_content("All of your discounts need to be of the same type.")

      end
    end
  end
end
