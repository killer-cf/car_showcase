class AddBrandAndModelToCar < ActiveRecord::Migration[7.1]
  def change
    add_reference :cars, :brand, null: false, foreign_key: true, type: :uuid
    add_reference :cars, :model, null: false, foreign_key: true, type: :uuid
  end
end
