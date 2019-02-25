class CreateDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :discounts do |t|
      t.integer :type
      t.integer :discount_amount
      t.integer :item_quantity_for_discount
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
