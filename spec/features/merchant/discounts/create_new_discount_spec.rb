require 'rails_helper'

RSpec.describe 'create new discount', type: :feature do
  context 'As a merchant' do
    context 'When I visit my discounts index page' do
      before :each do
        @merchant = create(:merchant)
        @item = create(:item, user: @merchant)
        @discount_1 = Discount.create!(discount_type: 0, quantity_for_discount: 50, discount_amount: 10, user: @merchant)
        @discount_2 = Discount.create!(discount_type: 0, quantity_for_discount: 100, discount_amount: 25, user: @merchant)
      end

      it 'I see a link to create a new discount' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_discounts_path

        expect(page).to have_link("Create New Discount")
        click_link "Create New Discount"
        expect(current_path).to eq()
      end

    end
  end
end
