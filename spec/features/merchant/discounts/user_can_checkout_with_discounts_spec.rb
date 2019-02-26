require 'rails_helper'

RSpec.describe 'As a registered user' do
  describe 'When I have discounts on my cart' do
    describe 'And I click on Checkout' do
      before :each do
        @merchant = create(:merchant)
        @customer = create(:user)
        @item_1 = create(:item, user: @merchant, name: "Atari", active: true, price: 5, inventory: 20)
        @item_2 = create(:item, user: @merchant, name: "Super Nintendo", active: true, price: 20, inventory: 20)

        #$10 off an order of $70 or more
        @discount = @merchant.discounts.create(discount_type: 0, discount_amount: 10, quantity_for_discount: 70)
        @discount_2 = @merchant.discounts.create(discount_type: 0, discount_amount: 3, quantity_for_discount: 5)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@customer)

      end
      it 'creates an order with the discount applied' do
        visit item_path(@item_1)
        #Order subtotal is $5
        click_button "Add to Cart"
        visit cart_path

        11.times do
          within "#item-#{@item_1.id}" do
            click_button 'Add more to cart'
          end
        end
        #Now the order subtotal is $60, all from item_1

        visit item_path(@item_2)
        click_button "Add to Cart"
        visit cart_path
        #Now the order subtotal is $80, so we get a discount
        #We get $10 off
        #Total for the order is 70
        click_button "Check out"
        new_order = Order.last

        expect(current_path).to eq(profile_orders_path)
        expect(page).to have_content('You have successfully checked out!')

        visit profile_orders_path
        expect(page).to have_content("Order ID #{new_order.id}")
        expect(new_order.total_cost.to_f).to eq(70)

      end
    end
  end
end
