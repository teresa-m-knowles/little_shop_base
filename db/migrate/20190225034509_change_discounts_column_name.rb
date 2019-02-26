class ChangeDiscountsColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :discounts, :item_quantity_for_discount, :quantity_for_discount
  end
end
