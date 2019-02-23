require 'rails_helper'

RSpec.describe 'As a merchant', type: :feature do
  context 'In the dashboard, there/s a todo list' do
    describe 'if I have items with placeholder images' do
      it 'shows all items that need an image' do
      end
      it 'each item is a link to the item/s edit page' do
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
