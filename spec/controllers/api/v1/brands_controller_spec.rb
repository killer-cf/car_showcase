require 'rails_helper'

describe Api::V1::BrandsController do
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
    let(:user) { create(:user, super: true) }

    it 'returns a success response' do
      request.headers['Authorization'] = "Bearer #{jwt}"
      create_list(:brand, 5)

      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body
      expect(json_response.count).to eq(5)
    end
  end

  describe 'GET #show' do
    context '' do
      let(:user) { create(:user, super: true) }

      it 'returns a success response' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        brand = create(:brand)

        get :show, params: { id: brand.to_param }, format: :json

        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body
        expect(json_response['name']).to eq(brand.name)
      end

      it 'does not show brand for unauthenticated user' do
        brand = create(:brand)

        get :show, params: { id: brand.to_param }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'authenticated but not super' do
      let(:user) { create(:user, super: false) }

      it 'does not show brand for non-super user' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        brand = create(:brand)

        get :show, params: { id: brand.to_param }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:user) { create(:user, super: true) }

      it 'creates a new Brand' do
        request.headers['Authorization'] = "Bearer #{jwt}"

        expect do
          post :create, params: { brand: { name: 'Ford' } },
                        format: :json
        end.to change(Brand, :count).by(1)
      end

      it 'renders a JSON response with the new brand' do
        request.headers['Authorization'] = "Bearer #{jwt}"

        post :create, params: { brand: { name: 'Ford' } },
                      format: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body
        expect(json_response['name']).to eq('Ford')
      end

      it 'does not create brand for unauthenticated user' do
        post :create, params: { brand: { name: 'Ford' } },
                      format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'user not super' do
      let(:user) { create(:user, super: false) }

      it 'does not create brand for non-super user' do
        request.headers['Authorization'] = "Bearer #{jwt}"

        post :create, params: { brand: { name: 'Ford' } },
                      format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:user) { create(:user, super: true) }
      let(:new_attributes) do
        { name: 'Ford' }
      end

      it 'updates the requested brand' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        brand = create(:brand)
        put :update, params: { id: brand.to_param, brand: new_attributes }, format: :json
        brand.reload
        expect(brand.name).to eq('Ford')
      end

      it 'does not update brand for unauthenticated user' do
        brand = create(:brand)

        put :update, params: { id: brand.to_param, brand: new_attributes }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'user not super' do
      let(:user) { create(:user, super: false) }

      it 'does not update brand for non-super user' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        brand = create(:brand)

        put :update, params: { id: brand.to_param, brand: { name: 'Ford' } }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    context '' do
      let(:user) { create(:user, super: true) }

      it 'deletes the Brand' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        brand = create(:brand)

        expect do
          delete :destroy, params: { id: brand.id }, format: :json
        end.to change(Brand, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end

      it 'does not delete brand for unauthenticated user' do
        brand = create(:brand)

        delete :destroy, params: { id: brand.id }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'user not super' do
      let(:user) { create(:user, super: false) }

      it 'does not delete brand for non-super user' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        brand = create(:brand)

        delete :destroy, params: { id: brand.id }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET #index_models' do
    let(:user) { create(:user) }

    it 'returns a success response' do
      brand = create(:brand)
      create_list(:model, 5, brand:)

      get :index_models, params: { id: brand.to_param }, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body
      expect(json_response.count).to eq(5)
    end
  end
end
