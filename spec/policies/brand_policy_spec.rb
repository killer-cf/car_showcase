require 'rails_helper'

RSpec.describe BrandPolicy, type: :policy do
  subject { described_class.new(user, brand) }

  let(:store) { create(:store) }
  let(:brand) { build(:brand) }

  context 'with super users' do
    let(:user) { create(:user, role: :super) }

    it { is_expected.to permit_all_actions }
  end

  context 'with visitors' do
    let(:user) { nil }

    it { is_expected.to permit_only_actions(%i[index]) }
  end

  context 'with administrators of stores' do
    let(:user) { create(:user, role: :admin) }
    let!(:employee) { create(:employee, store: store, user: user) }

    it { is_expected.to permit_only_actions(%i[index]) }
  end

  context 'with store owner' do
    let(:user) { store.user }

    it { is_expected.to permit_only_actions(%i[index]) }
  end
end
