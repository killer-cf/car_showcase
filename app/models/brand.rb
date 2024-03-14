class Brand < ApplicationRecord
  has_many :models
  has_many :cars

  validates :name, presence: true
end
