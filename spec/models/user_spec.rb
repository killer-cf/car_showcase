require 'rails_helper'

RSpec.describe User do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:tax_id) }

    it { is_expected.to validate_presence_of(:email) }

    it { is_expected.to validate_uniqueness_of(:tax_id) }

    it { is_expected.to validate_uniqueness_of(:email) }

    it { is_expected.to validate_length_of(:name).is_at_least(3) }

    it { is_expected.to validate_length_of(:name).is_at_most(50) }

    it { is_expected.to validate_content_type_of(:avatar).allowing('image/png', 'image/jpeg') }

    it { is_expected.to validate_size_of(:avatar).less_than(100.megabytes) }
  end

  describe '#valid_cpf_or_cnpj' do
    it 'adds an error if the tax_id is not a valid CPF or CNPJ' do
      user = described_class.new(tax_id: 'invalid')
      user.valid?
      expect(user.errors[:tax_id]).to include('não é um CPF ou CNPJ válido')
    end

    it 'is valid with a valid CPF' do
      user = described_class.new(tax_id: '452.875.860-19')
      user.valid?
      expect(user.errors[:tax_id]).not_to include('não é um CPF ou CNPJ válido')
    end

    it 'is valid with a valid CNPJ' do
      user = described_class.new(tax_id: '52.052.976/0001-01')
      user.valid?
      expect(user.errors[:tax_id]).not_to include('não é um CPF ou CNPJ válido')
    end
  end
end
