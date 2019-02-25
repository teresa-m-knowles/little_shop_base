require 'rails_helper'

RSpec.describe 'As a merchant' do
  context 'When I visit my dashboard' do
    before :each do
      @merchant = create(:merchant)
      @item = create(:item, user: @merchant)
      @discount_1 = Discount.create!(discount_type: 0, quantity_for_discount: 50, discount_amount: 10, user: @merchant)
      @discount_2 = Discount.create!(discount_type: 0, quantity_for_discount: 100, discount_amount: 25, user: @merchant)

    end
    it 'I see a link to view all of my discounts' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit dashboard_path(@merchant)

      expect(page).to have_link("View My Discounts")
      click_link "View My Discounts"
      expect(current_path).to eq(dashboard_discounts_path)

    end
  end
end
