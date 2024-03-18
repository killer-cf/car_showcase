class AddStoreIdToCar < ActiveRecord::Migration[7.1]
  def change
    add_reference :cars, :store, null: false, foreign_key: true
  end
end
