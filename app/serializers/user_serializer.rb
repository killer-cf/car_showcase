class UserSerializer < ApplicationSerializer
  attributes :id, :name, :tax_id, :created_at

  has_one :avatar

  def avatar
    return unless object.avatar.attached?

    {
      id: object.avatar.id,
      url: Rails.application.routes.url_helpers.rails_blob_url(object.avatar, only_path: true)
    }
  end
end
