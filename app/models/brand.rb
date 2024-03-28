class Brand < ApplicationRecord
  has_many :models, dependent: :destroy
  has_many :cars, dependent: :destroy

  validates :name, presence: true
end
