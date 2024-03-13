# frozen_string_literal: true

class Car < ApplicationRecord
  enum status: { inactive: 0, active: 5, sold: 10 }

  validates :name, :year, :status, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 1900, less_than: 2100 }
end
