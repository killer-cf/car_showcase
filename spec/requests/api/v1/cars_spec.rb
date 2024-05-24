require 'swagger_helper'

RSpec.describe 'api/v1/cars', type: :request do
  let(:user) { create(:user) }

  path '/api/v1/cars' do
    get('list cars') do
      tags 'Cars'
      produces 'application/json', 'application/xml'
      response(200, 'successful') do
        example 'application/json', :example_key, { cars: [{ id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                             name: 'Ford Focus',
                                                             year: 2018,
                                                             km: 23.500,
                                                             price: 60_000.00,
                                                             used: true,
                                                             created_at: '2021-08-10T00:00:00.000Z',
                                                             updated_at: '2021-08-10T00:00:00.000Z',
                                                             brand: 'Ford',
                                                             model: 'Focus' },
                                                           { id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                             name: 'Fiat Uno',
                                                             year: 2012,
                                                             km: 200.500,
                                                             price: 10_000.00,
                                                             used: true,
                                                             created_at: '2021-08-10T00:00:00.000Z',
                                                             updated_at: '2021-08-10T00:00:00.000Z',
                                                             brand: 'Fiat',
                                                             model: 'Uno' }],
                                                    meta: { current_page: 2,
                                                            next_page: 3,
                                                            prev_page: 1,
                                                            total_pages: 10,
                                                            total_count: 20 } }
        run_test!
      end
    end

    post('create car') do
      tags 'Cars'
      consumes 'multipart/form-data'
      parameter name: :store_id, in: :path, type: :string, description: 'store_id'
      parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'
      parameter name: :car, in: :formData, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          year: { type: :integer },
          price: { type: :decimal },
          km: { type: :decimal },
          used: { type: :boolean },
          brand_id: { type: :integer },
          model_id: { type: :integer },
          images: { type: :array, items: { type: :string, format: :binary } }
        },
        required: %w[name year brand_id model_id images price km used]
      }

      response '201', 'car created', use_as_request_example: true do
        let(:brand_id) { Brand.create!(name: 'Ford').id }
        let(:model_id) { Model.create!(name: 'Focus', brand_id:).id }
        let(:store_id) { create(:store, user:).id }
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:images) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/car.png'), 'image/png') }
        let(:car) do
          { name: 'Ford Focus', year: 2022, brand_id:, model_id:, images: [images], price: 100_000.00, km: 23.555,
            used: false }
        end
        run_test!
      end

      response '422', 'invalid request', use_as_request_example: true do
        let(:brand_id) { Brand.create!(name: 'Ford').id }
        let(:model_id) { Model.create!(name: 'Focus').id }
        let(:store_id) { create(:store, user:).id }
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:car) { { name: 'Ford Focus', year: 2022, status: 0, brand_id: } }
        run_test!
      end
    end
  end

  path '/api/v1/cars/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    get('show car') do
      tags 'Cars'
      response(200, 'successful') do
        example 'application/json', :example_key, { car: { id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                           name: 'Ford Focus 2018',
                                                           year: 2022,
                                                           brand: 'Ford',
                                                           created_at: '2021-08-10T00:00:00.000Z',
                                                           model: 'Focus' } }
        schema type: :object,
               properties: {
                 car: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     name: { type: :string },
                     year: { type: :integer },
                     brand: { type: :string },
                     model: { type: :string },
                     created_at: { type: :string }
                   },
                   required: %w[id name year brand model created_at]
                 }
               },
               required: ['car']

        let(:brand_id) { Brand.create!(name: 'Ford').id }
        let(:model_id) { Model.create!(name: 'Focus', brand_id:).id }
        let(:store_id) { create(:store, user:).id }
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) do
          car = Car.new(name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id:, store_id:, price: 100_000.00,
                        km: 23.555, used: true)
          image = fixture_file_upload('car.png', 'image/png')
          car.images.attach(image) && car.save!
          car.id
        end
        run_test!
      end

      put('update car') do
        tags 'Cars'
        consumes 'application/json'
        produces 'application/json'
        parameter name: :id, in: :path, type: :integer
        parameter name: :car, in: :body, schema: {
          type: :object,
          properties: {
            name: { type: :string },
            year: { type: :integer },
            status: { type: :integer },
            price: { type: :decimal },
            km: { type: :decimal },
            used: { type: :boolean },
            brand_id: { type: :integer },
            model_id: { type: :integer }
          },
          required: %w[name year status brand_id model_id price km used]
        }

        response(204, 'successful') do
          let(:brand_id) { Brand.create!(name: 'Ford').id }
          let(:model_id) { Model.create!(name: 'Focus', brand_id:).id }
          let(:store_id) { create(:store, user:).id }
          let(:id) do
            car = Car.new(name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id:, store_id:,
                          price: 100_000.00, km: 23.555, used: true)
            image = fixture_file_upload('car.png', 'image/png')
            car.images.attach(image) && car.save!
            car.id
          end
          let(:car) { { name: 'Ford Focus 2022' } }
          let(:authorization) { "Bearer #{generate_jwt(user)}" }
          run_test!
        end
      end

      delete('delete car') do
        tags 'Cars'
        response(204, 'successful') do
          let(:brand_id) { Brand.create!(name: 'Ford').id }
          let(:model_id) { Model.create!(name: 'Focus', brand_id:).id }
          let(:store_id) { create(:store, user:).id }
          let(:id) do
            car = Car.new(name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id:, store_id:,
                          price: 100_000.00, km: 23.555, used: true)
            image = fixture_file_upload('car.png', 'image/png')
            car.images.attach(image) && car.save!
            car.id
          end
          let(:authorization) { "Bearer #{generate_jwt(user)}" }
          run_test!
        end
      end
    end
  end

  path '/api/v1/cars/{id}/activate' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    patch('activate car') do
      tags 'Cars'
      response(204, 'successful') do
        let(:brand_id) { Brand.create!(name: 'Ford').id }
        let(:model_id) { Model.create!(name: 'Focus', brand_id:).id }
        let(:store_id) { create(:store, user:).id }
        let(:id) do
          car = Car.new(name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id:, store_id:,
                        price: 100_000.00, km: 23.555, used: true)
          image = fixture_file_upload('car.png', 'image/png')
          car.images.attach(image) && car.save!
          car.id
        end
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        run_test!
      end
    end
  end

  path '/api/v1/cars/{id}/sell' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    patch('sell car') do
      tags 'Cars'
      response(204, 'successful') do
        let(:brand_id) { Brand.create!(name: 'Ford').id }
        let(:model_id) { Model.create!(name: 'Focus', brand_id:).id }
        let(:store_id) { create(:store, user:).id }
        let(:id) do
          car = Car.new(name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id:, store_id:,
                        price: 100_000.00, km: 23.555, used: true)
          image = fixture_file_upload('car.png', 'image/png')
          car.images.attach(image) && car.save!
          car.id
        end
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        run_test!
      end
    end
  end
end
