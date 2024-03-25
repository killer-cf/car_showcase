class User < ApplicationRecord
  has_one :store, dependent: :destroy
  has_one :employee, dependent: :destroy
  has_one_attached :avatar

  validates :name, :tax_id, presence: true
  validates :tax_id, uniqueness: true
  validates :name, length: { minimum: 3, maximum: 50 }
  validate :valid_cpf_or_cnpj

  private

  def valid_cpf_or_cnpj
    return if CPF.valid?(tax_id) || CNPJ.valid?(tax_id)

    errors.add(:tax_id, 'não é um CPF ou CNPJ válido')
  end
end
