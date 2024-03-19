class AddKeycloakIdToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :keycloak_id, :string
    add_index :users, :keycloak_id
  end
end
