require 'rails_helper'

describe ApplicationHelper, :type => :helper do
  describe ".discount_to_words" do
    it "returns a string that interprets the discount info for a flat dollar discount" do
      merchant = create(:merchant)
      discount = merchant.discounts.create(discount_type: 0, discount_amount: 10, quantity_for_discount: 50)

      expect(helper.discount_to_words(discount)).to eq("$10 off an order of $50 or more")
    end

    it "returns a string that interprets the discount info for a percentage based discount" do
      merchant = create(:merchant)
      discount = merchant.discounts.create(discount_type: 1, discount_amount: 10, quantity_for_discount: 50)

      expect(helper.discount_to_words(discount)).to eq("10% off when you buy 50 or more items")
    end
  end
end
