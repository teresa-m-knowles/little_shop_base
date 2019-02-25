require 'rails_helper'

RSpec.describe 'As a merchant', type: :feature do
  describe 'I can edit a discount' do
    it 'it can edit a discount quantity or amount and redirect me to show page' do
      merchant = create(:merchant)
      discount_1 = merchant.discounts.create!(discount_type: 0, discount_amount: 50, quantity_for_discount: 100)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)
      visit edit_dashboard_discount_path(discount_1)

      fill_in "Discount amount", with: 150
      fill_in "Quantity for discount", with: 100
      click_on "Update Discount"

      expect(current_path).to eq(dashboard_discount_path(discount_1))
      expect(page).to have_content(discount_1.discount_type.capitalize)
      expect(page).to have_content("Quantity for discount: 100")
      expect(page).to have_content("Discount amount: 150")

    end
  end
end
