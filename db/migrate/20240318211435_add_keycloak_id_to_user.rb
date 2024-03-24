class AddKeycloakIdToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :keycloak_id, :string, type: :uuid
    add_index :users, :keycloak_id
  end
end
