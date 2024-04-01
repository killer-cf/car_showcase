require 'rails_helper'

RSpec.describe StorePolicy, type: :policy do
  subject { described_class.new(user, store) }

  let(:store) { build(:store, user: create(:user)) }

  context 'with super users' do
    let(:user) { create(:user, super: true) }

    it { is_expected.to permit_all_actions }
  end

  context 'with visitors' do
    let(:user) { nil }

    it { is_expected.to permit_only_actions(%i[show index]) }
  end

  context 'with administrators of stores' do
    let(:user) { create(:user) }
    let!(:employee) { create(:employee, store: store, user: user, role: :admin) }

    it { is_expected.to permit_only_actions(%i[show index]) }
  end

  context 'with store owner' do
    let(:user) { store.user }

    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_actions(%i[show index update destroy]) }
  end
end
