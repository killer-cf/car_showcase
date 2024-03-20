require 'rails_helper'

describe Api::V1::BrandsController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      create_list(:brand, 5)

      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body
      expect(json_response['brands'].count).to eq(5)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      brand = create(:brand)

      get :show, params: { id: brand.to_param }, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body
      expect(json_response['name']).to eq(brand.name)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Brand' do
        expect do
          post :create, params: { brand: { name: 'Ford' } },
                        format: :json
        end.to change(Brand, :count).by(1)
      end

      it 'renders a JSON response with the new brand' do
        post :create, params: { brand: { name: 'Ford' } },
                      format: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body
        expect(json_response['name']).to eq('Ford')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { name: 'Ford' }
      end

      it 'updates the requested brand' do
        brand = create(:brand)
        put :update, params: { id: brand.to_param, brand: new_attributes }, format: :json
        brand.reload
        expect(brand.name).to eq('Ford')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the Brand' do
      brand = create(:brand)

      expect do
        delete :destroy, params: { id: brand.id }, format: :json
      end.to change(Brand, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
