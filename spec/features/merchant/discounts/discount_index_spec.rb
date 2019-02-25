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
      expect(current_path).to eq(discounts_path)
    end

    it "I see the discount's type, quantity and amount" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit dashboard_path(@merchant)
      click_link "View My Discounts"

      within("#discount-#{@discount_1.id}") do
        expect(page).to have_content(@discount_1.discount_type)
        expect(page).to have_content(@discount_1.quantity_for_discount)
        expect(page).to have_content(@discount_1.discount_amount)
      end


      within("#discount-#{@discount_2.id}") do
        expect(page).to have_content(@discount_2.discount_type)
        expect(page).to have_content(@discount_2.quantity_for_discount)
        expect(page).to have_content(@discount_2.discount_amount)
      end

    end
  end
end
