require 'rails_helper'

RSpec.describe 'Delete a discount' do
  describe 'As a merchant ' do
    describe "when I go to a discount's show page" do
      before :each do
        @merchant = create(:merchant)
        @discount_1 = @merchant.discounts.create!(discount_type: 0, discount_amount: 50, quantity_for_discount: 100)
        @discount_2 = @merchant.discounts.create!(discount_type: 0, discount_amount: 20, quantity_for_discount: 30)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      end
      it "I see a button to delete that discount" do
        visit dashboard_discount_path(@discount_1)
        expect(page).to have_button("Delete")
      end

      describe 'when I click on the delete button on a discount show page' do
        it 'the discount is deleted and I am redirected to the discounts index' do
          visit dashboard_discount_path(@discount_1)

          click_link("Delete")
          # page.driver.browser.switch_to.alert.accept
          # page.driver.browser.accept_js_confirms


          # page.accept_confirm do
          #   click_link 'OK'
          # end
          expect(@merchant.discounts.count).to eq(1)
          expect(current_path).to eq(dashboard_discounts_path)
          expect(page).to_not have_content(@discount_1.id)
        end
      end

    end
  end
end
