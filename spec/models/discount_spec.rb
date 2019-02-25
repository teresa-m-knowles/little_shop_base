require 'rails_helper'

RSpec.describe Discount do
  describe 'validations' do
    it {should validate_presence_of :type}
    it {should validate_presence_of :discount_amount}
    it {should validate_presence_of :item_quantity_for_discount}
    
  end

  describe 'relationships' do
    it {should belong_to :user}
  end
end
