require 'rails_helper'

describe Api::V1::ModelsController do
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
    let!(:models) { create_list(:model, 5) }

    it 'returns a success response' do
      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body['models']
      expect(json_response.count).to eq(5)
    end

    it 'paginates results and provide metadata' do
      get :index, params: { page: 2, per_page: 2 }, format: :json

      json_response = response.parsed_body['models']
      expect(json_response.count).to eq(2)

      meta = response.parsed_body['meta']
      expect(meta['current_page']).to eq(2)
      expect(meta['next_page']).to eq(3)
      expect(meta['prev_page']).to eq(1)
      expect(meta['total_pages']).to eq(3)
      expect(meta['total_count']).to eq(5)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:brand_id) { create(:brand).id }
      let(:user) { create(:user, super: true) }

      it 'creates a new Model' do
        request.headers['Authorization'] = "Bearer #{jwt}"

        expect do
          post :create, params: { model: { name: 'Mustang', brand_id: } },
                        format: :json
        end.to change(Model, :count).by(1)
      end

      it 'renders a JSON response with the new model' do
        request.headers['Authorization'] = "Bearer #{jwt}"

        post :create, params: { model: { name: 'Mustang', brand_id: } },
                      format: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['model']
        expect(json_response['name']).to eq('Mustang')
        expect(json_response['brand_id']).to eq(brand_id)
      end

      it 'does not show model for unauthenticated user' do
        post :create, params: { model: { name: 'Mustang', brand_id: } },
                      format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'user not super' do
      let(:user) { create(:user, super: false) }
      let(:brand_id) { create(:brand).id }

      it 'does not create brand for non-super user' do
        request.headers['Authorization'] = "Bearer #{jwt}"

        post :create, params: { model: { name: 'Mustang', brand_id: } },
                      format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    context '' do
      let(:user) { create(:user, super: true) }

      it 'deletes the Model' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        model = create(:model)

        expect do
          delete :destroy, params: { id: model.id }, format: :json
        end.to change(Model, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end

      it 'does not delete model for unauthenticated user' do
        model = create(:model)

        delete :destroy, params: { id: model.id }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'user not super' do
      let(:user) { create(:user, super: false) }

      it 'does not delete model for non-super user' do
        request.headers['Authorization'] = "Bearer #{jwt}"
        model = create(:model)

        delete :destroy, params: { id: model.id }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
