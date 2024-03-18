class Store < ApplicationRecord
  validates :name, :tax_id, :phone, presence: true

  has_many :cars, dependent: :destroy
end