require 'rails_helper'

describe Api::V1::CarsController, type: :controller do
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
      json_response = JSON.parse(response.body)
      expect(json_response['cars'].count).to eq(15)
    end

    it 'filters by brand' do
      brand = brands.first
      get :index, params: { brand_id: brand.id }, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response['cars'].all? { |car| car['brand_id'] == brand.id }).to be_truthy
    end

    it 'filters by model' do
      model = models.first
      get :index, params: { model_id: model.id }, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response['cars'].all? { |car| car['model_id'] == model.id }).to be_truthy
    end

    it 'filters by name' do
      car_name = cars.first.name
      get :index, params: { search: car_name }, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response['cars'].all? { |car| car['name'].include?(car_name) }).to be_truthy
    end

    it 'paginates results' do
      get :index, params: { page: 2, per_page: 2 }, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response['cars'].count).to eq(2)
    end

    it 'combines filters' do
      brand = brands.first
      model = brand.models.first
      car_name = model.cars.first.name
      get :index, params: { brand_id: brand.id, model_id: model.id, search: car_name }, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response['cars'].count).to eq(1)
      expect(json_response['cars'].first['brand_id']).to eq(brand.id)
      expect(json_response['cars'].first['model_id']).to eq(model.id)
      expect(json_response['cars'].first['name']).to include(car_name)
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
      json_response = JSON.parse(response.body)
      expect(json_response['car']['name']).to eq(car.name)
      expect(json_response['car']['year']).to eq(car.year)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:brand_id) { create(:brand).id }
      let(:model_id) { create(:model, brand_id:).id }

      it 'creates a new Car' do
        expect do
          post :create, params: { car: { name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id: } },
                        format: :json
        end.to change(Car, :count).by(1)
      end

      it 'renders a JSON response with the new car' do
        post :create, params: { car: { name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id: } },
                      format: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = JSON.parse(response.body)
        expect(json_response['car']['name']).to eq('Ford Focus')
        expect(json_response['car']['year']).to eq(2022)
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new car' do
        post :create, params: { car: { name: 'Ford Focus' } }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:brand_id) { create(:brand).id }
      let(:model_id) { create(:model, brand_id:).id }

      let(:new_attributes) do
        { name: 'Ford Mustang' }
      end

      it 'updates the requested car' do
        car = create(:car, brand_id:, model_id:)
        put :update, params: { id: car.to_param, car: new_attributes }, format: :json
        car.reload
        expect(car.name).to eq('Ford Mustang')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the Car' do
      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:)

      expect do
        delete :destroy, params: { id: car.id }, format: :json
      end.to change(Car, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
