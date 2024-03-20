class CarSerializer < ApplicationSerializer
  attributes :id, :name, :year, :brand, :model, :created_at

  belongs_to :brand
  belongs_to :model

  def brand
    object.brand.name
  end

  def model
    object.model.name
  end
end
