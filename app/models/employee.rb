class Employee < ApplicationRecord
  enum role: { user: 0, admin: 10 }

  belongs_to :store
  belongs_to :user
end
