require 'swagger_helper'

RSpec.describe 'api/v1/models' do
  path '/api/v1/models' do
    get('list models') do
      tags 'Models'
      produces 'application/json', 'application/xml'
      response(200, 'successful') do
        example 'application/json', :example_key, [{ id: 'ddf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                     name: 'Mustang',
                                                     brand_id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                     created_at: '2021-08-10T00:00:00.000Z',
                                                     updated_at: '2021-08-10T00:00:00.000Z' },
                                                   { id: 'tff9cfdc-b795-45af-9f44-4f017ab105c3',
                                                     name: 'Maverick',
                                                     brand_id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                     created_at: '2021-08-10T00:00:00.000Z',
                                                     updated_at: '2021-08-10T00:00:00.000Z' }]

        run_test!
      end
    end

    post 'Creates a model' do
      tags 'Models'
      consumes 'application/json'
      parameter name: :model, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          brand_id: { type: :string }
        },
        required: %w[name brand_id]
      }
      request_body_example value: { name: 'Mustang', brand_id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3' }, name: '201',
                           summary: '201_response'

      response '201', 'model created' do
        let(:brand_id) { create(:brand).id }
        let(:model) { { name: 'foo', brand_id: } }
        run_test!
      end
    end
  end

  path '/api/v1/models/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show model') do
      tags 'Models'
      response(200, 'successful') do
        example 'application/json', :example_key, { id: 'ddf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                    name: 'Mustang',
                                                    brand_id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                    created_at: '2021-08-10T00:00:00.000Z',
                                                    updated_at: '2021-08-10T00:00:00.000Z' }
        schema type: :object,
               properties: {
                 id: { type: :string },
                 name: { type: :string },
                 brand_id: { type: :string }
               },
               required: %w[id name brand_id]

        let(:brand_id) { create(:brand).id }
        let(:id) { create(:model, brand_id:).id }
        run_test!
      end
    end

    put('update model') do
      tags 'Models'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :model, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          brand_id: { type: :string }
        },
        required: %w[name brand_id]
      }

      response(204, 'successful') do
        let(:brand_id) { create(:brand).id }
        let(:id) { create(:model, brand_id:).id }
        let(:model) { { name: 'foo' } }
        run_test!
      end
    end

    delete('delete model') do
      tags 'Models'
      response(204, 'successful') do
        let(:brand_id) { create(:brand).id }
        let(:id) { create(:model, brand_id:).id }
        run_test!
      end
    end
  end
end
