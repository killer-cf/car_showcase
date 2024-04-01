require 'swagger_helper'

RSpec.describe 'api/v1/brands' do
  let(:user) { create(:user, super: true) }
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
  end

  path '/api/v1/brands' do
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    get('list brands') do
      tags 'Brands'
      produces 'application/json', 'application/xml'
      response(200, 'successful') do
        let(:authorization) { "Bearer #{jwt}" }
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

      response(401, 'unauthorized') do
        let(:authorization) { nil }
        run_test!
      end

      response(403, 'forbidden') do
        let(:user) { create(:user) }
        let(:authorization) { "Bearer #{jwt}" }
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
        let(:authorization) { "Bearer #{jwt}" }

        let(:brand) { { name: 'foo' } }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:authorization) { nil }
        let(:brand) { { name: 'foo' } }
        run_test!
      end

      response(403, 'forbidden') do
        let(:user) { create(:user) }
        let(:authorization) { "Bearer #{jwt}" }
        let(:brand) { { name: 'foo' } }
        run_test!
      end
    end
  end

  path '/api/v1/brands/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    get('show brand') do
      tags 'Brands'
      response(200, 'successful') do
        let(:authorization) { "Bearer #{jwt}" }
        example 'application/json', :example_key, { brand: { id: 1,
                                                             name: 'Ford',
                                                             created_at: '2021-08-10T00:00:00.000Z',
                                                             updated_at: '2021-08-10T00:00:00.000Z' } }
        schema type: :object,
               properties: {
                 properties: {
                   id: { type: :integer },
                   name: { type: :string }
                 },
                 required: %w[id name]
               }

        let(:id) { Brand.create(name: 'Pegeout').id }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:authorization) { nil }
        let(:id) { Brand.create(name: 'Pegeout').id }
        run_test!
      end

      response(403, 'forbidden') do
        let(:user) { create(:user) }
        let(:id) { Brand.create(name: 'Pegeout').id }
        let(:authorization) { "Bearer #{jwt}" }
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
        let(:authorization) { "Bearer #{jwt}" }
        let(:id) { Brand.create(name: 'Pegeout').id }
        let(:brand) { { name: 'foo' } }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:authorization) { nil }
        let(:id) { Brand.create(name: 'Pegeout').id }
        let(:brand) { { name: 'foo' } }
        run_test!
      end

      response(403, 'forbidden') do
        let(:user) { create(:user) }
        let(:id) { Brand.create(name: 'Pegeout').id }
        let(:brand) { { name: 'foo' } }
        let(:authorization) { "Bearer #{jwt}" }
        run_test!
      end
    end

    delete('delete brand') do
      tags 'Brands'
      response(204, 'successful') do
        let(:authorization) { "Bearer #{jwt}" }

        let(:id) { Brand.create(name: 'Pegeout').id }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:authorization) { nil }
        let(:id) { Brand.create(name: 'Pegeout').id }
        run_test!
      end

      response(403, 'forbidden') do
        let(:user) { create(:user) }
        let(:id) { Brand.create(name: 'Pegeout').id }
        let(:authorization) { "Bearer #{jwt}" }
        run_test!
      end
    end
  end
end
