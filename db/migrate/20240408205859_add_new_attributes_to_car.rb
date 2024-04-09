class AddNewAttributesToCar < ActiveRecord::Migration[7.1]
  def change
    add_column :cars, :price, :decimal
    add_column :cars, :km, :decimal
    add_column :cars, :used, :boolean
  end
end
