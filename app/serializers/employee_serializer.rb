class EmployeeSerializer < ApplicationSerializer
  attributes :id, :store_id, :user_id, :created_at
  belongs_to :store
  belongs_to :user
end
