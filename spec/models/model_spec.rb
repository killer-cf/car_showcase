require 'rails_helper'

RSpec.describe Model do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to belong_to(:brand).required(true) }
  end
end
