class User < ApplicationRecord
  enum role: { user: 0, admin: 5, owner: 15, super: 20 }

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
