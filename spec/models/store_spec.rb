require 'rails_helper'

RSpec.describe Store do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:tax_id) }

    it { is_expected.to validate_presence_of(:phone) }

    it { is_expected.to belong_to(:user).required(true) }
  end

  describe '#valid_cpf_or_cnpj' do
    it 'adds an error if the tax_id is not a valid CPF or CNPJ' do
      store = described_class.new(tax_id: 'invalid')
      store.valid?
      expect(store.errors[:tax_id]).to include('não é um CPF ou CNPJ válido')
    end

    it 'is valid with a valid CPF' do
      store = described_class.new(tax_id: '452.875.860-19')
      store.valid?
      expect(store.errors[:tax_id]).not_to include('não é um CPF ou CNPJ válido')
    end

    it 'is valid with a valid CNPJ' do
      store = described_class.new(tax_id: '52.052.976/0001-01')
      store.valid?
      expect(store.errors[:tax_id]).not_to include('não é um CPF ou CNPJ válido')
    end
  end
end
