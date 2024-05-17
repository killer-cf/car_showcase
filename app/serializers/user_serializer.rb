class UserSerializer < ApplicationSerializer
  attributes :id, :name, :email, :tax_id, :role, :created_at

  has_one :avatar
  has_one :employee, serializer: EmployeeUserSerializer

  def avatar
    return unless object.avatar.attached?

    image_url = Rails.application.routes.url_helpers.rails_blob_url(object.avatar, only_path: true)

    {
      id: object.avatar.id,
      url: ENV.fetch('APP_URL') + image_url
    }
  end

  def role
    object.role.upcase
  end
end
