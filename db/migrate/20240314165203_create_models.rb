class CreateModels < ActiveRecord::Migration[7.1]
  def change
    create_table :models, id: :uuid do |t|
      t.string :name
      t.references :brand, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
