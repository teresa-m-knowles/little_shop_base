require 'rails_helper'

RSpec.describe 'As a merchant', type: :feature do
  context 'In the dashboard, there/s a todo list' do
    before :each do
      @merchant = create(:merchant)
      @item_1 = create(:item, name: "Item 1", price: 28.99, inventory: 10, user: @merchant, image: "https://vignette.wikia.nocookie.net/zeldaocarinaoftime/images/b/bf/Bomb_%28Ocarina_of_Time%29.png/revision/latest/scale-to-width-down/180?cb=20120826153735")
      @item_2 = create(:item, name: "Item 2", price: 55.32, inventory: 10, user: @merchant)
      @item_3 = create(:item, name: "Item 3", price: 23.17, inventory: 10, user: @merchant)

      @customer = create(:user)
      @pending_order_1 = create(:order, user: @customer)
      @pending_order_2 = create(:order, user: @customer)
      @pending_order_3 = create(:order, user: @customer)
      @oi1 = create(:order_item, order: @pending_order_1, item: @item_1, quantity: 5, price: 28.99)
      @oi2 = create(:order_item, order: @pending_order_2, item: @item_2, quantity: 5, price: 55.32)
      @oi3 = create(:order_item, order: @pending_order_3, item: @item_3, quantity: 5, price: 23.17)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit dashboard_path(@merchant)

    end
    describe 'if I have items with placeholder images' do
      it 'shows all items that need an image' do

        within("#to-do-list") do
          expect(page).to have_content("To Do List")
          within "#need-images" do
            expect(page).to have_content(@item_2.name)
            expect(page).to have_content(@item_3.name)
          end
        end

      end
      it 'each item is a link to the item/s edit page' do

        within("#to-do-list") do
          expect(page).to have_content("To Do List")
          within "#need-images" do
            expect(page).to have_link(@item_2.name)
            expect(page).to have_link(@item_3.name)
            click_link @item_2.name
          end
        end
        expect(current_path).to eq(edit_dashboard_item_path(@item_2))
      end
    end
    describe 'if I have unfulfilled items' do
      it 'I see how many unfulfilled items I have and their potential revenue' do


        within("#to-do-list") do
          within "#missed-revenue" do
            expect(page).to have_content("You have 3 unfulfilled orders worth $537.40.")
          end
        end
      end
    end
    describe 'if I have pending orders that my stock cannot cover' do
      it 'if I have enough inventory, I receive a good news notice' do
        visit dashboard_path(@merchant)
        within "#order-#{@pending_order_1.id}" do
          expect(page).to have_content("Good news! You have enough inventory to fulfill this order.")
        end
      end
      it 'next to the order, I see a warning if an item quantity exceeds my current stock' do
        visit root_path

        #fulfill order_items for orders 1,2,and 3 and mark orders as completed
        @oi1.fulfill
        @oi1.order.status = :completed
        @oi1.order.save
        @oi2.fulfill
        @oi2.order.status = :completed
        @oi2.order.save
        @oi3.fulfill
        @oi3.order.status = :completed
        @oi3.order.save
        #now item 1, 2 and 3 have 5 items in stock

        visit dashboard_path(@merchant)

        pending_order_4 = create(:order, user: @customer)
        oi4 = create(:order_item, order: pending_order_4, item: @item_3, quantity: 10, price: 23.17)

        pending_order_5 = create(:order, user: @customer)
        oi5 = create(:order_item, order: pending_order_5, item: @item_3, quantity: 7, price: 23.17)

        visit dashboard_path(@merchant)
        within "#order-#{pending_order_4.id}" do
          expect(page).to have_content("Not enough in stock to fulfill this order")
        end
      end
    end
    describe 'if I have multiple orders for an item that collectively exceed my stock for that item' do
      it 'I should see a warning message letting me know that the sum of those orders exceed my stock' do
        OrderItem.destroy_all
        Item.destroy_all
        Order.destroy_all

        new_item = create(:item, name: "Ocarina of Time", inventory: 10, user: @merchant)
        new_item_2 = create(:item, name: "Majora", inventory: 10, user: @merchant)
        pending_order_4 = create(:order, user: @customer)
        pending_order_5 = create(:order, user: @customer)
        oi4 = create(:order_item, order: pending_order_4, item: new_item, quantity: 7)
        oi5 = create(:order_item, order: pending_order_5, item: new_item, quantity: 4)
        oi6 = create(:order_item, order: pending_order_5, item: new_item_2, quantity: 4)

        binding.pry

        visit dashboard_path(@merchant)


        within('#to-do-list') do
          expect(page).to have_content("Several orders combined exceed your current inventory of #{new_item.name}. You cannot fulfill them all.")
        end

      end
    end
  end
end
