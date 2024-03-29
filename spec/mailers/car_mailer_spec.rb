require 'rails_helper'

RSpec.describe CarMailer, type: :mailer do
  describe 'car_sold' do
    let(:model) { create(:model) }
    let(:car) { create(:car, name: 'Car 1', brand: model.brand, model:) }
    let(:mail) { described_class.with(car:).car_sold }

    it 'renders the headers' do
      expect(mail.subject).to eq('Car sold')
      expect(mail.to).to eq(['costa.kilder@live.com'])
      expect(mail.from).to eq('Car Showcase')
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Car 1')
    end
  end
end
