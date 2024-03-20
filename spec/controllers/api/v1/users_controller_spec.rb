require 'rails_helper'

describe Api::V1::UsersController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      create_list(:user, 5)

      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body
      expect(json_response['users'].count).to eq(5)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      user = create(:user)

      get :show, params: { id: user.to_param }, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body
      expect(json_response['name']).to eq(user.name)
      expect(json_response['tax_id']).to eq(user.tax_id)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        expect do
          post :create, params: { user: { name: 'Kilder', tax_id: '31.576.685/0001-42' } }, format: :json
        end.to change(User, :count).by(1)
      end

      it 'renders a JSON response with the new user' do
        post :create, params: { user: { name: 'Kilder', tax_id: '31.576.685/0001-42' } }, format: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body
        expect(json_response['name']).to eq('Kilder')
        expect(json_response['tax_id']).to eq('31.576.685/0001-42')
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
        user = User.create(name: 'Joao', tax_id: '31.576.685/0001-42')
        put :update, params: { id: user.to_param, user: new_attributes }, format: :json
        user.reload
        expect(user.name).to eq('Kilder')
      end
    end
  end
end
