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
        expect(current_path)
      end

      it 'If I create a new discount, I get a success message' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit new_dashboard_discount_path
        choose(option: 'dollar')
        fill_in "Discount amount", with: 150
        fill_in "Quantity for discount", with: 200
        click_on "Submit"

        discount = Discount.last

        expect(@merchant.discounts.last).to eq(discount)
        expect(current_path).to eq(dashboard_discounts_path)
        expect(page).to have_content(discount.id)
        expect(page).to have_content("New discount created")
      end

      it 'if I create a discount with wrong information I get an error message' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit new_dashboard_discount_path
        choose(option: "dollar")
        fill_in "Discount amount", with: "string"
        fill_in "Quantity for discount", with: 200
        click_on "Submit"
        expect(page).to_not have_content("New discount created")
        expect(page).to have_content("Discount amount is not a number")
      end

      it 'I need to choose a discount type' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit new_dashboard_discount_path
        fill_in "Discount amount", with: 5
        fill_in "Quantity for discount", with: 200
        click_on "Submit"
        expect(page).to_not have_content("New discount created")
        expect(page).to have_content("Discount type can't be blank")
      end

      context 'If I have discounts in my system' do
        it 'any new discounts have to be of the same type' do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
          visit new_dashboard_discount_path
          #choose wrong type:
          choose(option: 'percentage')
          fill_in "Discount amount", with: 150
          fill_in "Quantity for discount", with: 200
          click_on "Submit"

          expect(page).to_not have_content("New discount created")
          expect(page).to have_content("All of your discounts need to be of the same type.")



        end
      end

      context 'if I have no discounts in my system' do
        it 'any new discounts can be of any type' do
          Discount.destroy_all

          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
          visit new_dashboard_discount_path
          choose(option: 'percentage')
          fill_in "Discount amount", with: 150
          fill_in "Quantity for discount", with: 200
          click_on "Submit"

          discount = Discount.last

          expect(@merchant.discounts.last).to eq(discount)
          expect(current_path).to eq(dashboard_discounts_path)
          expect(page).to have_content(discount.id)
          expect(page).to have_content("New discount created")


        end
      end

    end
  end
end
