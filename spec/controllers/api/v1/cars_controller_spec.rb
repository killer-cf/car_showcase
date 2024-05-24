require 'rails_helper'

describe Api::V1::CarsController do
  let(:user) { create(:user) }
  let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

  describe 'GET #index' do
    let!(:brands) { create_list(:brand, 3) }
    let!(:models) { brands.map { |brand| create(:model, brand:) } }
    let!(:cars) do
      models.flat_map do |model|
        create_list(:car, 5, brand: model.brand, model:, status: :active)
      end
    end

    it 'returns a success response' do
      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body['cars']
      expect(json_response.count).to eq(15)
    end

    it 'filters by brand' do
      brand = brands.first
      get :index, params: { brand: brand.name }, format: :json

      json_response = response.parsed_body['cars']
      expect(json_response).to(be_all { |car| car['brand'] == brand.name })
    end

    it 'filters by model' do
      model = models.first
      get :index, params: { model: model.name }, format: :json

      json_response = response.parsed_body['cars']
      expect(json_response).to(be_all { |car| car['model'] == model.name })
    end

    it 'filters by name' do
      car_name = cars.first.name
      get :index, params: { search: car_name }, format: :json

      json_response = response.parsed_body['cars']
      expect(json_response).to(be_all { |car| car['name'].include?(car_name) })
    end

    it 'paginates results and provide metadata' do
      get :index, params: { page: 2, per_page: 2 }, format: :json

      json_response = response.parsed_body['cars']
      expect(json_response.count).to eq(2)

      meta = response.parsed_body['meta']
      expect(meta['total_count']).to eq(15)
      expect(meta['total_pages']).to eq(8)
      expect(meta['current_page']).to eq(2)
      expect(meta['next_page']).to eq(3)
      expect(meta['prev_page']).to eq(1)
    end

    it 'combines filters' do
      brand = brands.first
      model = brand.models.first
      car_name = model.cars.first.name
      get :index, params: { brand: brand.name, model: model.name, search: car_name }, format: :json

      json_response = response.parsed_body['cars']
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
      json_response = response.parsed_body['car']
      expect(json_response['name']).to eq(car.name)
      expect(json_response['year']).to eq(car.year)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:brand_id) { create(:brand).id }
      let(:images) { fixture_file_upload('car.png', 'image/png') }
      let(:model_id) { create(:model, brand_id:).id }

      it 'creates a new Car and return it as json' do
        create(:store, user:)
        request.headers.merge!(authorization)

        expect do
          post :create, params: { car: { name: 'Ford Focus', year: 2022, brand_id:, model_id:, images: [images],
                                         price: 100_000.00, km: 23_500.00, used: true } },
                        format: :json
        end.to change(Car, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['car']
        expect(json_response['name']).to eq('Ford Focus')
        expect(json_response['year']).to eq(2022)
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new car' do
        create(:store, user:)
        request.headers.merge!(authorization)

        post :create, params: { car: { name: 'Ford Focus' } }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'without authentication' do
      it 'unauthenticated' do
        create(:store, user:)
        post :create, params: { car: { name: 'Ford Focus' } }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'unauthorized (no store)' do
        request.headers.merge!(authorization)

        post :create, params: { car: { name: 'Ford Focus' } }, format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:brand) { create(:brand) }
      let(:model) { create(:model, brand:) }
      let(:store_id) { create(:store).id }

      let(:new_attributes) do
        { name: 'Ford Mustang' }
      end

      it 'updates the requested car' do
        request.headers.merge!(authorization)

        car = create(:car, brand:, model:, store: create(:store, user:))
        put :update, params: { id: car.to_param, store_id: car.store_id, car: new_attributes }, format: :json
        car.reload
        expect(car.name).to eq('Ford Mustang')
      end

      it 'does not update the car for unauthenticated user' do
        car = create(:car, brand:, model:)

        put :update, params: { id: car.to_param, store_id: car.store_id, car: new_attributes }, format: :json
        car.reload
        expect(car.name).not_to eq('Ford Mustang')
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update the car for unauthorized user' do
        car = create(:car, brand:, model:)

        request.headers.merge!(authorization)

        put :update, params: { id: car.to_param, store_id: car.store_id, car: new_attributes }, format: :json
        car.reload
        expect(car.name).not_to eq('Ford Mustang')
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the Car' do
      request.headers.merge!(authorization)

      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:, store: create(:store, user:))

      expect do
        delete :destroy, params: { id: car.id, store_id: car.store_id }, format: :json
      end.to change(Car, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'does not delete the car for unauthenticated user' do
      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:)

      expect do
        delete :destroy, params: { id: car.id, store_id: car.store_id }, format: :json
      end.not_to change(Car, :count)
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not delete the car for unauthorized user' do
      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:)

      request.headers.merge!(authorization)

      expect do
        delete :destroy, params: { id: car.id, store_id: car.store_id }, format: :json
      end.not_to change(Car, :count)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'PATCH #activate' do
    it 'activates the Car' do
      request.headers.merge!(authorization)

      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:, store: create(:store, user:), status: :inactive)

      patch :activate, params: { id: car.id, store_id: car.store_id }, format: :json
      car.reload
      expect(car).to be_active
    end

    it 'does not activate the car for unauthenticated user' do
      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:, status: :inactive)

      patch :activate, params: { id: car.id, store_id: car.store_id }, format: :json
      car.reload
      expect(car).not_to be_active
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not activate the car for unauthorized user' do
      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:, status: :inactive)

      request.headers.merge!(authorization)

      patch :activate, params: { id: car.id, store_id: car.store_id }, format: :json
      car.reload
      expect(car).not_to be_active
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'PATCH #sell' do
    it 'sells the Car' do
      request.headers.merge!(authorization)

      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:, store: create(:store, user:), status: :active)

      patch :sell, params: { id: car.id, store_id: car.store_id }, format: :json
      car.reload
      expect(car).to be_sold
    end

    it 'does not sell the car for unauthenticated user' do
      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:, status: :active)

      patch :sell, params: { id: car.id, store_id: car.store_id }, format: :json
      car.reload
      expect(car).not_to be_sold
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not sell the car for unauthorized user' do
      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:, status: :active)

      request.headers.merge!(authorization)

      patch :sell, params: { id: car.id, store_id: car.store_id }, format: :json
      car.reload
      expect(car).not_to be_sold
      expect(response).to have_http_status(:forbidden)
    end

    it 'sends an email when the car is sold' do
      request.headers.merge!(authorization)

      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:, store: create(:store, user:), status: :active)

      expect do
        patch :sell, params: { id: car.id, store_id: car.store_id }, format: :json
      end.to have_enqueued_job.on_queue('default')
    end
  end
end
