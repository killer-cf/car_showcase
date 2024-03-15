require 'rails_helper'

describe Api::V1::ModelsController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      5.times do
        create(:model)
      end

      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = JSON.parse(response.body)
      expect(json_response['models'].count).to eq(5)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      model = create(:model)

      get :show, params: { id: model.to_param }, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = JSON.parse(response.body)
      expect(json_response['model']['name']).to eq(model.name)
      expect(json_response['model']['brand_id']).to eq(model.brand_id)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:brand_id) { create(:brand).id }

      it 'creates a new Model' do
        expect do
          post :create, params: { model: { name: 'Mustang', brand_id: } },
                        format: :json
        end.to change(Model, :count).by(1)
      end

      it 'renders a JSON response with the new model' do
        post :create, params: { model: { name: 'Mustang', brand_id: } },
                      format: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = JSON.parse(response.body)
        expect(json_response['model']['name']).to eq('Mustang')
        expect(json_response['model']['brand_id']).to eq(brand_id)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { name: 'Mustang' }
      end

      it 'updates the requested model' do
        model = create(:model)
        put :update, params: { id: model.to_param, model: new_attributes }, format: :json
        model.reload
        expect(model.name).to eq('Mustang')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the Model' do
      model = create(:model)

      expect do
        delete :destroy, params: { id: model.id }, format: :json
      end.to change(Model, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
