require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:tax_id) }

    it { is_expected.to validate_uniqueness_of(:tax_id) }

    it { is_expected.to validate_length_of(:name).is_at_least(3) }

    it { is_expected.to validate_length_of(:name).is_at_most(50) }
  end

  describe '#valid_cpf_or_cnpj' do
    it 'adds an error if the tax_id is not a valid CPF or CNPJ' do
      user = User.new(tax_id: 'invalid')
      user.valid?
      expect(user.errors[:tax_id]).to include('não é um CPF ou CNPJ válido')
    end

    it 'is valid with a valid CPF' do
      user = User.new(tax_id: '452.875.860-19')
      user.valid?
      expect(user.errors[:tax_id]).to_not include('não é um CPF ou CNPJ válido')
    end

    it 'is valid with a valid CNPJ' do
      user = User.new(tax_id: '52.052.976/0001-01')
      user.valid?
      expect(user.errors[:tax_id]).to_not include('não é um CPF ou CNPJ válido')
    end
  end
end
