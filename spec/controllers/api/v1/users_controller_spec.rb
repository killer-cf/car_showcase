require 'rails_helper'

describe Api::V1::UsersController do
  describe 'GET #index' do
    let!(:users) { create_list(:user, 5) }

    it 'returns a success response' do
      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body['users']
      expect(json_response.count).to eq(5)
    end

    it 'paginates results and provide metadata' do
      get :index, params: { page: 2, per_page: 2 }, format: :json

      json_response = response.parsed_body['users']
      expect(json_response.count).to eq(2)

      meta = response.parsed_body['meta']
      expect(meta['current_page']).to eq(2)
      expect(meta['next_page']).to eq(3)
      expect(meta['prev_page']).to eq(1)
      expect(meta['total_pages']).to eq(3)
      expect(meta['total_count']).to eq(5)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      user = create(:user)

      get :show, params: { id: user.to_param }, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body['user']
      expect(json_response['name']).to eq(user.name)
      expect(json_response['tax_id']).to eq(user.tax_id)
      expect(json_response['email']).to eq(user[:email])
      expect(json_response['avatar']).to be_nil
      expect(json_response['role']).to eq('USER')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:avatar) { fixture_file_upload('person.jpeg', 'image/jpeg') }

      it 'creates a new User without avatar' do
        expect do
          post :create, params: { user: attributes_for(:user) },
                        format: :json
        end.to change(User, :count).by(1)
      end

      it 'creates a new User with avatar' do
        expect do
          post :create,
               params: { user: attributes_for(:user).merge(avatar: avatar) },
               format: :json
        end.to change(User, :count).by(1)
        json_response = response.parsed_body['user']
        expect(json_response['avatar']['url']).to be_present
      end

      it 'renders a JSON response with the new user' do
        user = attributes_for(:user)

        post :create, params: { user: }, format: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['user']
        expect(json_response['name']).to eq(user[:name])
        expect(json_response['tax_id']).to eq(user[:tax_id])
        expect(json_response['email']).to eq(user[:email])
        expect(json_response['avatar']).to be_nil
        expect(json_response['role']).to eq('USER')
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new user' do
        post :create, params: { user: { name: 'Kilder' } }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { name: 'Kilder' }
      end

      it 'updates the requested user' do
        user = create(:user, name: 'Joao', tax_id: '31.576.685/0001-42')
        put :update, params: { id: user.to_param, user: new_attributes }, format: :json
        user.reload
        expect(user.name).to eq('Kilder')
      end
    end
  end

  describe 'GET #show_by_supabase_id' do
    it 'returns a success response' do
      user = create(:user)

      get :show_by_supabase_id, params: { supabase_id: user.supabase_id }, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body['user']
      expect(json_response['name']).to eq(user.name)
      expect(json_response['tax_id']).to eq(user.tax_id)
      expect(json_response['email']).to eq(user[:email])
      expect(json_response['avatar']).to be_nil
      expect(json_response['role']).to eq('USER')
    end
  end
end
