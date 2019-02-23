require 'rails_helper'

RSpec.describe 'As a merchant', type: :feature do
  context 'In the dashboard, there/s a todo list' do
    before :each do
      @merchant = create(:merchant)
      @item_1 = create(:item, name: "Item 1", user: @merchant, image: "https://vignette.wikia.nocookie.net/zeldaocarinaoftime/images/b/bf/Bomb_%28Ocarina_of_Time%29.png/revision/latest/scale-to-width-down/180?cb=20120826153735")
      @item_2 = create(:item, name: "Item 2", user: @merchant)
      @item_3 = create(:item, name: "Item 3", user: @merchant)
    end
    describe 'if I have items with placeholder images' do
      it 'shows all items that need an image' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_path(@merchant)

        within("#to-do-list") do
          expect(page).to have_content("To Do List")
          within "#need-images" do
            expect(page).to have_content(@item_2.name)
            expect(page).to have_content(@item_3.name)
          end
        end

      end
      it 'each item is a link to the item/s edit page' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_path(@merchant)

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
      it 'I see how many unfulfilled items I have and their revenue' do
      end
    end
    describe 'if I have pending orders that my stock cannot cover' do
      it 'next to the order, I see a warning if an item quantity exceeds my current stock' do
      end
    end
    describe 'if I have multiple orders for an item that collectively exceed my stock for that item' do
      it 'I should see a warning message letting me know that the sum of those orders exceed my stock' do
      end
    end
  end
end
