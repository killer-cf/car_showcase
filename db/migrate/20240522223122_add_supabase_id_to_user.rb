class AddSupabaseIdToUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :keycloak_id
    add_column :users, :supabase_id, :string
    add_index :users, :supabase_id
  end
end
