class User < ApplicationRecord
  validates :name, :tax_id, presence: true
  validates :tax_id, uniqueness: true
  validates :name, length: { minimum: 3, maximum: 50 }
end
