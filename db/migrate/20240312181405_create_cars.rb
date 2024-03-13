# frozen_string_literal: true

class CreateCars < ActiveRecord::Migration[7.1]
  def change
    create_table :cars do |t|
      t.string :name
      t.integer :year
      t.integer :status

      t.timestamps
    end
  end
end