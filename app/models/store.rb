class Store < ApplicationRecord
  validates :name, :tax_id, :phone, presence: true
  validate :valid_cpf_or_cnpj

  has_many :cars, dependent: :destroy
  belongs_to :user

  private

  def valid_cpf_or_cnpj
    return if CPF.valid?(tax_id) || CNPJ.valid?(tax_id)

    errors.add(:tax_id, 'não é um CPF ou CNPJ válido')
  end
end
