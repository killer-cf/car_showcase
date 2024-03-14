require 'rails_helper'

RSpec.describe Brand, type: :model do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to have_many(:cars) }

    it { is_expected.to have_many(:models) }
  end
end
