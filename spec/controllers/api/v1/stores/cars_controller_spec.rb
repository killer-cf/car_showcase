require 'rails_helper'

describe Api::V1::Stores::CarsController, type: :controller do
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

  describe 'POST #create' do
    context 'with valid params' do
      let(:brand_id) { create(:brand).id }
      let(:model_id) { create(:model, brand_id:).id }
      let(:store_id) { create(:store).id }

      it 'creates a new Car and return it as json' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        allow_any_instance_of(Authentication).to receive(:current_user_roles).and_return(['ADMIN'])

        expect do
          post :create, params: { car: { name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id: }, store_id: },
                        format: :json
        end.to change(Car, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = JSON.parse(response.body)
        expect(json_response['car']['name']).to eq('Ford Focus')
        expect(json_response['car']['year']).to eq(2022)
      end
    end

    context 'with invalid params' do
      let(:store_id) { create(:store).id }

      it 'renders a JSON response with errors for the new car' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        allow_any_instance_of(Authentication).to receive(:current_user_roles).and_return(['ADMIN'])

        post :create, params: { car: { name: 'Ford Focus' }, store_id: }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'without authentication' do
      let(:store_id) { create(:store).id }

      it 'unauthenticated' do
        post :create, params: { car: { name: 'Ford Focus' }, store_id: }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'unauthorized' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        allow_any_instance_of(Authentication).to receive(:current_user_roles).and_return(['USER'])

        post :create, params: { car: { name: 'Ford Focus' }, store_id: }, format: :json
        expect(response).to have_http_status(:forbidden)
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
        request.headers['Authorization'] = "Bearer #{jwt}"
        allow_any_instance_of(Authentication).to receive(:current_user_roles).and_return(['ADMIN'])

        car = create(:car, brand:, model:)
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

        request.headers['Authorization'] = "Bearer #{jwt}"
        allow_any_instance_of(Authentication).to receive(:current_user_roles).and_return(['USER'])

        put :update, params: { id: car.to_param, store_id: car.store_id, car: new_attributes }, format: :json
        car.reload
        expect(car.name).not_to eq('Ford Mustang')
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the Car' do
      request.headers['Authorization'] = "Bearer #{jwt}"
      allow_any_instance_of(Authentication).to receive(:current_user_roles).and_return(['ADMIN'])

      brand = create(:brand)
      model = create(:model, brand:)
      car = create(:car, brand:, model:)

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

      request.headers['Authorization'] = "Bearer #{jwt}"
      allow_any_instance_of(Authentication).to receive(:current_user_roles).and_return(['USER'])

      expect do
        delete :destroy, params: { id: car.id, store_id: car.store_id }, format: :json
      end.not_to change(Car, :count)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
