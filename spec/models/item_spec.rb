require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :description }
    it { should validate_presence_of :inventory }
    it { should validate_numericality_of(:inventory).only_integer }
    it { should validate_numericality_of(:inventory).is_greater_than_or_equal_to(0) }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :order_items }
    it { should have_many(:orders).through(:order_items) }
  end

  describe 'class methods' do
    describe '.not_enough_in_stock' do
      it 'returns an array of items for which the merchant does not have enough stock to fulfill the order items and the missed revenue' do
        merchant = create(:merchant)
        item_1 = create(:item, inventory: 10, user: merchant, price: 5)
        item_2 = create(:item, inventory: 20, user: merchant, price: 7.35)
        item_3 = create(:item, inventory: 30, user: merchant, price: 11.50)

        customer = create(:user)
        order_1 = create(:order, user: customer)
        order_2 = create(:order, user: customer)
        create(:order_item, order: order_1, item: item_1, quantity: 7)
        create(:order_item, order: order_2, item: item_1, quantity: 4)

        create(:order_item, order: order_1, item: item_2, quantity: 10)
        create(:order_item, order: order_2, item: item_2, quantity: 13)

        create(:order_item, order: order_1, item: item_3, quantity: 20)
        create(:order_item, order: order_2, item: item_3, quantity: 10)

        expect(merchant.items.not_enough_in_stock).to eq([item_1, item_2])

        expect(merchant.items.not_enough_in_stock[0]).to eq(item_1)
        expect(merchant.items.not_enough_in_stock[0].revenue).to eq(55)

        expect(merchant.items.not_enough_in_stock[1]).to eq(item_2)
        expect(merchant.items.not_enough_in_stock[1].revenue).to eq(169.05)

    end

    end
    describe 'item popularity' do
      before :each do
        merchant = create(:merchant)
        @items = create_list(:item, 6, user: merchant)
        user = create(:user)

        order = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order, item: @items[3], quantity: 7)
        create(:fulfilled_order_item, order: order, item: @items[1], quantity: 6)
        create(:fulfilled_order_item, order: order, item: @items[0], quantity: 5)
        create(:fulfilled_order_item, order: order, item: @items[2], quantity: 3)
        create(:fulfilled_order_item, order: order, item: @items[5], quantity: 2)
        create(:fulfilled_order_item, order: order, item: @items[4], quantity: 1)
      end
      it '.item_popularity' do
        expect(Item.item_popularity(4, :desc)).to eq([@items[3], @items[1], @items[0], @items[2]])
        expect(Item.item_popularity(4, :asc)).to eq([@items[4], @items[5], @items[2], @items[0]])
      end
      it '.popular_items' do
        actual = Item.popular_items(3)
        expect(actual).to eq([@items[3], @items[1], @items[0]])
        expect(actual[0].total_ordered).to eq(7)
      end
      it '.unpopular_items' do
        actual = Item.unpopular_items(3)
        expect(actual).to eq([@items[4], @items[5], @items[2]])
        expect(actual[0].total_ordered).to eq(1)
      end
    end
  end

  describe 'instance methods' do
    describe '.avg_time_to_fulfill' do
      scenario 'happy path, with orders' do
        user = create(:user)
        merchant = create(:merchant)
        item = create(:item, user: merchant)
        order_1 = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order_1, item: item, quantity: 5, price: 2, created_at: 3.days.ago, updated_at: 1.day.ago)
        order_2 = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order_2, item: item, quantity: 5, price: 2, created_at: 1.days.ago, updated_at: 1.hour.ago)

        actual = item.avg_time_to_fulfill[0..13]
        expect(actual).to eq('1 day 11:30:00')
      end
      scenario 'sad path, no orders' do
        user = create(:user)
        merchant = create(:merchant)
        item = create(:item, user: merchant)

        expect(item.avg_time_to_fulfill).to eq('n/a')
      end
    end
  end

  it '.ever_ordered?' do
    item_1, item_2, item_3, item_4, item_5 = create_list(:item, 5)

    order = create(:completed_order)
    create(:fulfilled_order_item, order: order, item: item_1, created_at: 4.days.ago, updated_at: 1.days.ago)

    order = create(:order)
    create(:fulfilled_order_item, order: order, item: item_2, created_at: 4.days.ago, updated_at: 1.days.ago)
    create(:order_item, order: order, item: item_3, created_at: 4.days.ago, updated_at: 1.days.ago)

    order = create(:order)
    create(:order_item, order: order, item: item_4, created_at: 4.days.ago, updated_at: 1.days.ago)

    expect(item_1.ever_ordered?).to eq(true)
    expect(item_2.ever_ordered?).to eq(false)
    expect(item_3.ever_ordered?).to eq(false)
    expect(item_4.ever_ordered?).to eq(false)
    expect(item_5.ever_ordered?).to eq(false)
  end
end
