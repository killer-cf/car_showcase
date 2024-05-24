require 'swagger_helper'

RSpec.describe 'api/v1/users' do
  path '/api/v1/users' do
    get('list users') do
      tags 'Users'
      produces 'application/json', 'application/xml'
      response(200, 'successful') do
        example 'application/json', :example_key, { users: [{ id: 'ddf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                              name: 'Kilder costa',
                                                              tax_id: '31.576.685/0001-42',
                                                              role: 'ADMIN',
                                                              email: 'kilder@live.com',
                                                              created_at: '2021-08-10T00:00:00.000Z',
                                                              avatar: 'null',
                                                              employee: { id: 'ddf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                                          store_id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3' } },
                                                            { id: 'tff9cfdc-b795-45af-9f44-4f017ab105c3',
                                                              name: 'Leticia costa',
                                                              tax_id: '31.576.685/0001-42',
                                                              role: 'ADMIN',
                                                              email: 'kilder@live.com',
                                                              created_at: '2021-08-10T00:00:00.000Z',
                                                              avatar: {
                                                                id: 'ddf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                                url: 'http://localhost:3000/uploads/user/avatar/1/person.jpeg'
                                                              },
                                                              employee: { id: 'ddf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                                          store_id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3' } }],
                                                    meta: { current_page: 2,
                                                            next_page: 3,
                                                            prev_page: 1,
                                                            total_pages: 10,
                                                            total_count: 20 } }
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
        let(:user) { attributes_for(:user).merge(avatar: avatar) }
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
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     name: { type: :string },
                     emai: { type: :string },
                     role: { type: :string },
                     tax_id: { type: :string },
                     created_at: { type: :string },
                     avatar: {
                       type: :object,
                       nullable: true,
                       properties: {
                         id: { type: :string },
                         url: { type: :string }
                       }
                     },
                     employee: {
                       type: :object,
                       nullable: true,
                       properties: {
                         id: { type: :string },
                         store_id: { type: :string }
                       }
                     }
                   },
                   required: %w[id name tax_id created_at]
                 }
               },
               required: ['user']

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
          tax_id: { type: :string },
          email: { type: :string }
        }
      }

      response(204, 'successful') do
        let(:id) { create(:user, name: 'Joao', tax_id: '31.576.685/0001-42').id }
        let(:user) { { name: 'foo', tax_id: '452.875.860-19', email: 'costa@live.com' } }
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

  path '/api/v1/supabase/users/{supabase_id}' do
    parameter name: 'supabase_id', in: :path, type: :string, description: 'supabase user id'

    get('show user') do
      tags 'Users'
      response(200, 'successful') do
        example 'application/json', :example_key, { id: 'string-uuid', name: 'Kilder', tax_id: '31.576.685/0001-42' }
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     name: { type: :string },
                     emai: { type: :string },
                     role: { type: :string },
                     tax_id: { type: :string },
                     created_at: { type: :string },
                     avatar: {
                       type: :object,
                       nullable: true,
                       properties: {
                         id: { type: :string },
                         url: { type: :string }
                       }
                     },
                     employee: {
                       type: :object,
                       nullable: true,
                       properties: {
                         id: { type: :string },
                         store_id: { type: :string }
                       }
                     }
                   },
                   required: %w[id name tax_id created_at]
                 }
               },
               required: ['user']

        let(:supabase_id) { create(:user, name: 'Joao', tax_id: '31.576.685/0001-42').supabase_id }
        run_test!
      end
    end
  end
end
