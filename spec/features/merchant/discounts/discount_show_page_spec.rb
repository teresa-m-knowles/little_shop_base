require 'rails_helper'

RSpec.describe 'As a merchant' do
  describe "When I visit a discount's show page" do
    it "I see the discount's type, amount and quantity" do
      merchant = create(:merchant)
      discount_1 = merchant.discounts.create!(discount_type: 0, discount_amount: 50, quantity_for_discount: 100)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)
      visit dashboard_discount_path(discount_1)
      
      expect(page).to have_content(discount_1.id)
      expect(page).to have_content("Type: Dollar")
      expect(page).to have_content("Quantity for discount: #{discount_1.quantity_for_discount}")
      expect(page).to have_content("Discount amount: #{discount_1.discount_amount}")
      expect(page).to have_link ("Edit")
    end
  end
end
