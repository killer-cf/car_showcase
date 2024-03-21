require 'rails_helper'

RSpec.describe Car do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:year) }

    it { is_expected.to validate_presence_of(:status) }

    it { is_expected.to belong_to(:brand).required(true) }

    it { is_expected.to belong_to(:model).required(true) }

    it { is_expected.to belong_to(:store).required(true) }

    it { is_expected.to validate_numericality_of(:year).is_greater_than(1900) }

    it { is_expected.to validate_numericality_of(:year).is_less_than(2100) }
  end
end
