class CreateDiscountsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :discounts_tables do |t|
      t.integer :type
      t.integer :discount_amount
      t.integer :item_quantity_for_discount
      t.references :user, foreign_key: true
    end
  end
end
