require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  path '/api/v1/users' do
    get('list users') do
      tags 'Users'
      produces 'application/json', 'application/xml'
      response(200, 'successful') do
        run_test!
      end
    end

    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          tax_id: { type: :string }
        },
        required: %w[name tax_id]
      }
      request_body_example value: { name: 'Kilder', tax_id: '31.576.685/0001-42' }, name: '201', summary: '201_response'
      request_body_example value: { name: 'Kilder' }, name: '422', summary: '422_response'

      response '201', 'user created' do
        let(:user) { { name: 'foo', tax_id: '31.576.685/0001-42' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { { name: 'foo' } }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show user') do
      tags 'Users'
      response(200, 'successful') do
        example 'application/json', :example_key, { id: 1, name: 'Kilder', tax_id: '31.576.685/0001-42' }
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            tax_id: { type: :string }
          },
          required: %w[id name tax_id]

        let(:id) { User.create(name: 'Joao', tax_id: '31.576.685/0001-42').id }
        run_test!
      end
    end

    put('update user') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          tax_id: { type: :string }
        },
        required: %w[name tax_id]
      }

      response(204, 'successful') do
        let(:id) { User.create(name: 'Joao', tax_id: '31.576.685/0001-42').id }
        let(:user) { { name: 'foo', tax_id: '452.875.860-19' } }
        run_test!
      end
    end

    delete('delete user') do
      tags 'Users'
      response(204, 'successful') do
        let(:id) { User.create(name: 'Joao', tax_id: '31.576.685/0001-42').id }
        run_test!
      end
    end
  end
end
