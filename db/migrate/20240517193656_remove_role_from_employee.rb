class RemoveRoleFromEmployee < ActiveRecord::Migration[7.1]
  def change
    remove_column :employees, :role
    remove_column :users, :super
    add_column :users, :role, :integer, default: 0
  end
end
