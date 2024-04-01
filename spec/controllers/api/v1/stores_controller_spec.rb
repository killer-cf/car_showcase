require 'rails_helper'

describe Api::V1::StoresController do
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
    let(:user) { create(:user, super: false) }

    it 'returns a success response' do
      request.headers['Authorization'] = "Bearer #{jwt}"
      create_list(:store, 5)

      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body
      expect(json_response.count).to eq(5)
    end
  end

  describe 'GET #show' do
    let(:user) { create(:user, super: false) }

    it 'returns a success response' do
      request.headers['Authorization'] = "Bearer #{jwt}"
      store = create(:store)

      get :show, params: { id: store.to_param }, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body
      expect(json_response['name']).to eq(store.name)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:user) { create(:user, super: true) }
      let(:store) { attributes_for(:store).merge(user_id: user.id) }

      it 'creates a new Store' do
        request.headers['Authorization'] = "Bearer #{jwt}"

        expect do
          post :create, params: { store: },
                        format: :json
        end.to change(Store, :count).by(1)
      end

      it 'renders a JSON response with the new store' do
        request.headers['Authorization'] = "Bearer #{jwt}"

        post :create, params: { store: },
                      format: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body
        expect(json_response['name']).to eq(store[:name])
      end

      it 'does not create store for unauthenticated user' do
        post :create, params: { store: { name: 'Ford' } },
                      format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'user not super' do
      let(:user) { create(:user, super: false) }

      it 'does not create store for non-super user' do
        request.headers['Authorization'] = "Bearer #{jwt}"

        post :create, params: { store: { name: 'Ford' } },
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

      it 'updates the requested store' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        store = create(:store)
        put :update, params: { id: store.to_param, store: new_attributes }, format: :json
        store.reload
        expect(store.name).to eq('Ford')
      end

      it 'does not update store for unauthenticated user' do
        store = create(:store)

        put :update, params: { id: store.to_param, store: new_attributes }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'user not super' do
      let(:user) { create(:user, super: false) }

      it 'does not update store for non-super user' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        store = create(:store)

        put :update, params: { id: store.to_param, store: { name: 'Ford' } }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    context '' do
      let(:user) { create(:user, super: true) }

      it 'deletes the Store' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        store = create(:store)

        expect do
          delete :destroy, params: { id: store.id }, format: :json
        end.to change(Store, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end

      it 'does not delete store for unauthenticated user' do
        store = create(:store)

        delete :destroy, params: { id: store.id }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'user not super' do
      let(:user) { create(:user, super: false) }

      it 'does not delete store for non-super user' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        store = create(:store)

        delete :destroy, params: { id: store.id }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
