class ChangeColumnDefaultFromCars < ActiveRecord::Migration[7.1]
  def change
    change_column_default(:cars, :status, 5)
  end
end
