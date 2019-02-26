require 'rails_helper'

RSpec.describe 'As a registered user', type: :feature do
  context 'When I visit my cart' do
    context 'Dollar type discounts' do
      context 'and I have enough quantity to have a bulk discount' do
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

        it 'The bulk discount of dollar type shows up on my cart show page' do
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

          expect(page).to have_content("Total: $70.00")
          expect(page).to have_content("Discount: -$10")

        end

        it 'I only get a discount from that one merchant' do
          other_merchant = create(:merchant)
          other_merchant.discounts.create(discount_type: 0, discount_amount: 30, quantity_for_discount: 5)
          item_3 = create(:item, user: other_merchant, name: "Playstation", active: true, price: 20, inventory: 20)

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

          visit item_path(item_3)
          #Sutotal for this item is $20
          click_button "Add to Cart"
          visit cart_path
          #Order total is $100, minus the $10 discount is $90
          expect(page).to have_content "Total: $90.00 "
        end

      end

      context 'and I have not surpassed the value or item quantity to get a discount' do
        before :each do
          @merchant = create(:merchant)
          @customer = create(:user)
          @item_1 = create(:item, user: @merchant, name: "Atari", active: true, price: 5, inventory: 20)
          @item_2 = create(:item, user: @merchant, name: "Super Nintendo", active: true, price: 20, inventory: 20)

          #$10 off an order of $70 or more
          @discount = @merchant.discounts.create(discount_type: 0, discount_amount: 10, quantity_for_discount: 70)
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@customer)

        end
        it 'I do not see a bulk discount in my cart' do
          visit item_path(@item_1)
          #Order subtotal is $5
          click_button "Add to Cart"
          visit cart_path


          8.times do
            within "#item-#{@item_1.id}" do
              click_button 'Add more to cart'
            end
          end
          #Now the order subtotal is $45, all from item_1

          visit item_path(@item_2) #costs $20
          click_button "Add to Cart"
          visit cart_path
          #Now the order subtotal is $65, so we do not get a discount
          expect(page).to_not have_content("Discount")
          expect(page).to have_content("Total: $65.00")

        end
      end
    end

    context 'Percentage type discounts' do
      context 'and I add enough of one item to have a bulk discount' do
        before :each do
          @merchant = create(:merchant)
          @item_1 = create(:item, user: @merchant, price: 25, inventory: 50)
          @item_2 = create(:item, user: @merchant, price: 30, inventory: 50)
          #10% off when you buy 20 items or more
          @discount = @merchant.discounts.create(discount_type: 1, discount_amount: 10, quantity_for_discount: 20)
          @customer = create(:user)
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@customer)

        end
        it 'I get a discount on that item' do
          #Add 20 of item 1
          visit item_path(@item_1)
          click_button "Add to Cart"
          visit cart_path

          19.times do
            within "#item-#{@item_1.id}" do
              click_button 'Add more to cart'
            end
          end
          #Order subtotal: $500 with a 10% discount, so $450
          #------------------------------------------------------------------
          #Adds 11 of item 2
          #
          visit item_path(@item_2)
          click_button "Add to Cart"
          visit cart_path

          10.times do
            within "#item-#{@item_2.id}" do
              click_button 'Add more to cart'
            end
          end
          #Order subtotal $330
          #---------------------------------------------------------------------
          #Order total should be $780 with discount
          #No discounts applied is $830
          visit cart_path
          expect(page).to have_content("Total: $780.00")
          save_and_open_page


        end

      end
    end
  end
end
