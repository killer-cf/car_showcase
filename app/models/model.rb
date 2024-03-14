class Model < ApplicationRecord
  belongs_to :brand, dependent: :destroy
  has_many :cars, dependent: :nullify

  validates :name, :brand, presence: true
end
