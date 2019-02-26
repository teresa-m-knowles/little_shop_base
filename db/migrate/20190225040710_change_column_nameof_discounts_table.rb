class ChangeColumnNameofDiscountsTable < ActiveRecord::Migration[5.1]
  def change
    rename_column :discounts, :type, :discount_type

  end
end
