require 'rails_helper'

RSpec.describe CarPolicy, type: :policy do
  subject { described_class.new(user, car) }

  let(:model) { create(:model) }
  let(:store) { create(:store) }
  let(:car) { build(:car, store:, model:, brand: model.brand) }

  context 'with visitors' do
    let(:user) { nil }

    it { is_expected.to permit_only_actions(%i[index show]) }
    it { is_expected.to forbid_actions(%i[create update destroy]) }
  end

  context 'with administrators' do
    let(:user) { create(:user) }
    let!(:employee) { create(:employee, store: store, user: user, role: :admin) }

    it { is_expected.to permit_all_actions }
  end

  context 'with store owner' do
    let(:user) { store.user }

    it { is_expected.to permit_all_actions }
  end
end
