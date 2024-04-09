require 'rails_helper'

RSpec.describe Car do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:year) }

    it { is_expected.to validate_presence_of(:status) }

    it { is_expected.to validate_presence_of(:price) }

    it { is_expected.to validate_presence_of(:km) }

    it { is_expected.to validate_presence_of(:used) }

    it { is_expected.to belong_to(:brand).required(true) }

    it { is_expected.to belong_to(:model).required(true) }

    it { is_expected.to belong_to(:store).required(true) }

    it { is_expected.to validate_numericality_of(:year).is_greater_than(1900) }

    it { is_expected.to validate_numericality_of(:year).is_less_than(2100) }

    it { is_expected.to validate_numericality_of(:km).is_greater_than_or_equal_to(0.0) }

    it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0.0) }

    it { is_expected.to validate_attached_of(:images) }

    it { is_expected.to validate_content_type_of(:images).allowing('image/png', 'image/jpeg') }

    it { is_expected.to validate_size_of(:images).less_than(100.megabytes) }
  end
end
