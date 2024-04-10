class CarSerializer < ApplicationSerializer
  attributes :id, :name, :year, :brand, :model, :price, :km, :used, :created_at

  belongs_to :brand
  belongs_to :model
  has_many :images

  def brand
    object.brand.name
  end

  def model
    object.model.name
  end

  def images
    object.images.map do |image|
      image_url = Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)

      {
        id: image.id,
        url: ENV.fetch('APP_URL') + image_url
      }
    end
  end
end
