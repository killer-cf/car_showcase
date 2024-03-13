require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:tax_id) }

    it { is_expected.to validate_uniqueness_of(:tax_id) }

    it { is_expected.to validate_length_of(:name).is_at_least(3) }

    it { is_expected.to validate_length_of(:name).is_at_most(50) }
  end
end
