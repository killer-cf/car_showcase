require 'rails_helper'

describe Api::V1::CarsController do
  let(:user) { create(:user) }
  let(:jwt) do
    claims = {
      iat: Time.zone.now.to_i,
      exp: 1.day.from_now.to_i,
      sub: user.keycloak_id
    }
    token = JSON::JWT.new(claims)
    token.kid = 'default'
    token.sign($private_key, :RS256).to_s
  end

  before do
    request.env['REQUEST_URI'] = api_v1_cars_path
    public_key_resolver = Keycloak.public_key_resolver
    allow(public_key_resolver).to receive(:find_public_keys) {
                                    JSON::JWK::Set.new(JSON::JWK.new($private_key, kid: 'default'))
                                  }
  end

  describe 'GET #index' do
    let!(:brands) { create_list(:brand, 3) }
    let!(:models) { brands.map { |brand| create(:model, brand:) } }
    let!(:cars) do
      models.flat_map do |model|
        create_list(:car, 5, brand: model.brand, model:)
      end
    end

    it 'returns a success response' do
      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body
      expect(json_response.count).to eq(15)
    end

    it 'filters by brand' do
      brand = brands.first
      get :index, params: { brand: brand.name }, format: :json

      json_response = response.parsed_body
      expect(json_response).to(be_all { |car| car['brand'] == brand.name })
    end

    it 'filters by model' do
      model = models.first
      get :index, params: { model: model.name }, format: :json

      json_response = response.parsed_body
      expect(json_response).to(be_all { |car| car['model'] == model.name })
    end

    it 'filters by name' do
      car_name = cars.first.name
      get :index, params: { search: car_name }, format: :json

      json_response = response.parsed_body
      expect(json_response).to(be_all { |car| car['name'].include?(car_name) })
    end

    it 'paginates results' do
      get :index, params: { page: 2, per_page: 2 }, format: :json

      json_response = response.parsed_body
      expect(json_response.count).to eq(2)
    end

    it 'combines filters' do
      brand = brands.first
      model = brand.models.first
      car_name = model.cars.first.name
      get :index, params: { brand: brand.name, model: model.name, search: car_name }, format: :json

      json_response = response.parsed_body
      expect(json_response.count).to eq(1)
      expect(json_response.first['brand']).to eq(brand.name)
      expect(json_response.first['model']).to eq(model.name)
      expect(json_response.first['name']).to include(car_name)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:)

      get :show, params: { id: car.to_param }, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body
      expect(json_response['name']).to eq(car.name)
      expect(json_response['year']).to eq(car.year)
    end
  end
end
