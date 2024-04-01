require 'rails_helper'

RSpec.describe ModelPolicy, type: :policy do
  subject { described_class.new(user, model) }

  let(:store) { create(:store) }
  let(:model) { build(:model) }

  context 'with super users' do
    let(:user) { create(:user, super: true) }

    it { is_expected.to permit_actions(%i[create destroy]) }
  end

  context 'with visitors' do
    let(:user) { nil }

    it { is_expected.to permit_only_actions(%i[index]) }
  end

  context 'with administrators of stores' do
    let(:user) { create(:user) }
    let!(:employee) { create(:employee, store: store, user: user, role: :admin) }

    it { is_expected.to permit_only_actions(%i[index]) }
  end

  context 'with store owner' do
    let(:user) { store.user }

    it { is_expected.to permit_only_actions(%i[index]) }
  end
end
