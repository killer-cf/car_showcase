require 'swagger_helper'

RSpec.describe 'api/v1/users' do
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
      consumes 'multipart/form-data'
      parameter name: :user, in: :formData, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          tax_id: { type: :string },
          email: { type: :string },
          avatar: { type: :string, format: :binary }
        },
        required: %w[name tax_id email]
      }

      response '201', 'user created' do
        let(:avatar) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/person.jpeg'), 'image/jpeg') }
        let(:user) { { name: 'foo', tax_id: '31.576.685/0001-42', avatar:, email: 'foo@gmail.com' } }
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
        example 'application/json', :example_key, { id: 'string-uuid', name: 'Kilder', tax_id: '31.576.685/0001-42' }
        schema type: :object,
               properties: {
                 id: { type: :string },
                 name: { type: :string },
                 tax_id: { type: :string }
               },
               required: %w[id name tax_id]

        let(:id) { create(:user, name: 'Joao', tax_id: '31.576.685/0001-42').id }
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
        let(:id) { create(:user, name: 'Joao', tax_id: '31.576.685/0001-42').id }
        let(:user) { { name: 'foo', tax_id: '452.875.860-19' } }
        run_test!
      end
    end

    delete('delete user') do
      tags 'Users'
      response(204, 'successful') do
        let(:id) { create(:user).id }
        run_test!
      end
    end
  end
end
