class Model < ApplicationRecord
  belongs_to :brand, dependent: :destroy
end
