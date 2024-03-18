class CreateStores < ActiveRecord::Migration[7.1]
  def change
    create_table :stores do |t|
      t.string :name
      t.string :tax_id
      t.string :phone

      t.timestamps
    end
  end
end
