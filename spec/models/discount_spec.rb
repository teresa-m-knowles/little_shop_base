require 'rails_helper'

RSpec.describe Discount do
  describe 'validations' do
    it {should validate_presence_of :discount_type}

    it {should validate_presence_of :discount_amount}
    it { should validate_numericality_of(:discount_amount).is_greater_than(0) }
    it { should validate_numericality_of(:discount_amount).only_integer }


    it {should validate_presence_of :quantity_for_discount}
    it { should validate_numericality_of(:quantity_for_discount).is_greater_than(0) }
    it { should validate_numericality_of(:quantity_for_discount).only_integer }


  end

  describe 'relationships' do
    it {should belong_to :user}
  end
end
