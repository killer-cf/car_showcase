require 'swagger_helper'

RSpec.describe 'api/v1/cars', type: :request do
  let(:user) { create(:user) }
  let(:jwt) do
    claims = {
      iat: Time.zone.now.to_i,
      exp: 1.day.from_now.to_i,
      sub: user.keycloak_id
    }
    token = JSON::JWT.new(claims)
    token.kid = 'default'
    token.sign($private_key, :RS256).to_s
  end

  before do
    public_key_resolver = Keycloak.public_key_resolver
    allow(public_key_resolver).to receive(:find_public_keys) {
                                    JSON::JWK::Set.new(JSON::JWK.new($private_key, kid: 'default'))
                                  }
    allow_any_instance_of(Authentication).to receive(:current_user_roles).and_return(['ADMIN'])
  end

  path '/api/v1/cars' do
    get('list cars') do
      tags 'Cars'
      produces 'application/json', 'application/xml'
      response(200, 'successful') do
        example 'application/json', :example_key, { cars: [{ id: 1,
                                                             name: 'Ford Focus',
                                                             year: 2022,
                                                             created_at: '2021-08-10T00:00:00.000Z',
                                                             updated_at: '2021-08-10T00:00:00.000Z',
                                                             brand_id: 1,
                                                             model_id: 1 },
                                                           { id: 2,
                                                             name: 'Fiat Uno',
                                                             year: 2022,
                                                             created_at: '2021-08-10T00:00:00.000Z',
                                                             updated_at: '2021-08-10T00:00:00.000Z',
                                                             brand_id: 2,
                                                             model_id: 2 }] }
        run_test!
      end
    end
  end

  path '/api/v1/cars/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :Authorization, in: :header, type: :string, default: 'Bearer <token>'

    get('show car') do
      tags 'Cars'
      response(200, 'successful') do
        example 'application/json', :example_key, { id: 1,
                                                    name: 'Ford Focus 2018',
                                                    year: 2022,
                                                    brand: 'Ford',
                                                    created_at: '2021-08-10T00:00:00.000Z',
                                                    model: 'Focus' }
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 year: { type: :integer },
                 brand: { type: :string },
                 model: { type: :string },
                 created_at: { type: :string }
               },
               required: %w[id name year brand model created_at]

        let(:brand_id) { Brand.create!(name: 'Ford').id }
        let(:model_id) { Model.create!(name: 'Focus', brand_id:).id }
        let(:store_id) { create(:store).id }
        let(:Authorization) { "Bearer #{jwt}" }
        let(:id) { Car.create!(name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id:, store_id:).id }
        run_test!
      end
    end
  end

  path '/api/v1/stores/{store_id}/cars' do
    post('create car') do
      tags 'Cars'
      consumes 'application/json'
      parameter name: :store_id, in: :path, type: :string, description: 'store_id'
      parameter name: :Authorization, in: :header, type: :string, default: 'Bearer <token>'
      parameter name: :car, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          year: { type: :integer },
          status: { type: :integer },
          brand_id: { type: :integer },
          model_id: { type: :integer }
        },
        required: %w[name year status brand_id model_id]
      }
      request_body_example value: { name: 'Ford Focus', year: 2022, status: 0, brand_id: 1, model_id: 1 },
                           name: '201', summary: '201_response'

      request_body_example value: { name: 'Ford Focus', year: 2022, status: 0, brand_id: 1 },
                           name: '422', summary: '422_response'

      response '201', 'car created' do
        let(:brand_id) { Brand.create!(name: 'Ford').id }
        let(:model_id) { Model.create!(name: 'Focus', brand_id:).id }
        let(:store_id) { create(:store).id }
        let(:Authorization) { "Bearer #{jwt}" }
        let(:car) { { name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id: } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:brand_id) { Brand.create!(name: 'Ford').id }
        let(:model_id) { Model.create!(name: 'Focus').id }
        let(:store_id) { create(:store).id }
        let(:Authorization) { "Bearer #{jwt}" }
        let(:car) { { name: 'Ford Focus', year: 2022, status: 0, brand_id: } }
        run_test!
      end
    end
  end

  path '/api/v1/stores/{store_id}/cars/{id}' do
    parameter name: 'store_id', in: :path, type: :string, description: 'store_id'
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :Authorization, in: :header, type: :string, default: 'Bearer <token>'

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
          brand_id: { type: :integer },
          model_id: { type: :integer }
        },
        required: %w[name year status brand_id model_id]
      }

      response(204, 'successful') do
        let(:brand_id) { Brand.create!(name: 'Ford').id }
        let(:model_id) { Model.create!(name: 'Focus', brand_id:).id }
        let(:store_id) { create(:store).id }
        let(:id) { Car.create!(name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id:, store_id:).id }
        let(:car) { { name: 'Ford Focus 2022' } }
        let(:Authorization) { "Bearer #{jwt}" }
        run_test!
      end
    end

    delete('delete car') do
      tags 'Cars'
      response(204, 'successful') do
        let(:brand_id) { Brand.create!(name: 'Ford').id }
        let(:model_id) { Model.create!(name: 'Focus', brand_id:).id }
        let(:store_id) { create(:store).id }
        let(:id) { Car.create!(name: 'Ford Focus', year: 2022, status: 0, brand_id:, model_id:, store_id:).id }
        let(:Authorization) { "Bearer #{jwt}" }
        run_test!
      end
    end
  end
end
