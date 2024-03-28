class AddIndexTaxIdToUser < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :tax_id, unique: true
  end
end
