class EmployeeSerializer < ApplicationSerializer
  attributes :id
  belongs_to :store
  belongs_to :user
end
