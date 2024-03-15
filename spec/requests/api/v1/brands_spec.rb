require 'swagger_helper'

RSpec.describe 'api/v1/brands', type: :request do
  path '/api/v1/brands' do
    get('list brands') do
      tags 'Brands'
      produces 'application/json', 'application/xml'
      response(200, 'successful') do
        example 'application/json', :example_key, { brands: [{ id: 1,
                                                               name: 'Ford',
                                                               created_at: '2021-08-10T00:00:00.000Z',
                                                               updated_at: '2021-08-10T00:00:00.000Z' },
                                                             { id: 2,
                                                               name: 'Fiat',
                                                               created_at: '2021-08-10T00:00:00.000Z',
                                                               updated_at: '2021-08-10T00:00:00.000Z' }] }

        run_test!
      end
    end

    post 'Creates a brand' do
      tags 'Brands'
      consumes 'application/json'
      parameter name: :brand, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: %w[name]
      }
      request_body_example value: { name: 'Ford' }, name: '201', summary: '201_response'

      response '201', 'brand created' do
        let(:brand) { { name: 'foo' } }
        run_test!
      end
    end
  end

  path '/api/v1/brands/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show brand') do
      tags 'Brands'
      response(200, 'successful') do
        example 'application/json', :example_key, { brand: { id: 1,
                                                             name: 'Ford',
                                                             created_at: '2021-08-10T00:00:00.000Z',
                                                             updated_at: '2021-08-10T00:00:00.000Z' } }
        schema type: :object,
          properties: {
            brand: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string }
              },
              required: %w[id name]
            }
          },
          required: ['brand']

        let(:id) { Brand.create(name: 'Pegeout').id }
        run_test!
      end
    end

    put('update brand') do
      tags 'Brands'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer
      parameter name: :brand, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: %w[name]
      }

      response(204, 'successful') do
        let(:id) { Brand.create(name: 'Pegeout').id }
        let(:brand) { { name: 'foo' } }
        run_test!
      end
    end

    delete('delete brand') do
      tags 'Brands'
      response(204, 'successful') do
        let(:id) { Brand.create(name: 'Pegeout').id }
        run_test!
      end
    end
  end
end
