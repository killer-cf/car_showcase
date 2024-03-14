require 'rails_helper'

RSpec.describe Model, type: :model do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:brand) }

    it { should belong_to(:brand) }
  end
end
