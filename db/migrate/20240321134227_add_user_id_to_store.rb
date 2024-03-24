class AddUserIdToStore < ActiveRecord::Migration[7.1]
  def change
    add_reference :stores, :user, null: false, foreign_key: true, type: :uuid
  end
end
