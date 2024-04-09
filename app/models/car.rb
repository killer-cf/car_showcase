class Car < ApplicationRecord
  enum status: { inactive: 0, active: 5, sold: 10 }

  belongs_to :model
  belongs_to :brand
  belongs_to :store
  has_many_attached :images

  validates :name, :year, :status, :price, :km, :used, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 1900, less_than: 2100 }
  validates :km, :price, numericality: { greater_than_or_equal_to: 0.0 }
  validates :images, attached: true,
                     content_type: %i[png jpeg],
                     limit: { min: 1, max: 5 },
                     size: { less_than: 100.megabytes }
end
