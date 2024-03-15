require 'rails_helper'

describe Api::V1::CarsController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      brand = create(:brand)
      model = create(:model, brand:)
      5.times do
        create(:car, brand:, model:)
      end

      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = JSON.parse(response.body)
      expect(json_response['cars'].count).to eq(5)
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
