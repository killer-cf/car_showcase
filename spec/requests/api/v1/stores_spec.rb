require 'swagger_helper'

RSpec.describe 'api/v1/stores' do
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

  path '/api/v1/stores' do
    get('list stores') do
      tags 'Stores'
      produces 'application/json', 'application/xml'
      response(200, 'successful') do
        example 'application/json', :example_key, { stores: [{ id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                               name: 'Ford Store',
                                                               phone: '81981316877',
                                                               tax_id: '68005188000102',
                                                               created_at: '2021-08-10T00:00:00.000Z' },
                                                             { id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                               name: 'Fiat Store',
                                                               phone: '81981316877',
                                                               tax_id: '68005188000102',
                                                               created_at: '2021-08-10T00:00:00.000Z' }] }
        run_test!
      end
    end

    post('create store') do
      tags 'Stores'
      consumes 'application/json'
      parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'
      parameter name: :store, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          phone: { type: :string },
          tax_id: { type: :string },
          user_id: { type: :string }
        },
        required: %w[name phone tax_id user_id]
      }

      response '201', 'store created' do
        let(:user) { create(:user, super: true) }
        let(:authorization) { "Bearer #{jwt}" }
        let(:store) { { name: 'Fiat Store', phone: '81981316877', tax_id: '84737100000195', user_id: user.id } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { create(:user, super: true) }
        let(:authorization) { "Bearer #{jwt}" }
        let(:store) { { name: 'Fiat Store', phone: '81981316877', tax_id: '84737100000195' } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:user) { create(:user, super: false) }
        let(:authorization) { nil }
        let(:store) { { name: 'Fiat Store', phone: '81981316877', tax_id: '84737100000195' } }
        run_test!
      end

      response '403', 'forbidden' do
        let(:user) { create(:user, super: false) }
        let(:authorization) { "Bearer #{jwt}" }
        let(:store) { { name: 'Fiat Store', phone: '81981316877', tax_id: '84737100000195' } }
        run_test!
      end
    end
  end

  path '/api/v1/stores/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    get('show store') do
      tags 'Stores'
      response(200, 'successful') do
        example 'application/json', :example_key, { store: { id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                             name: 'Fiat Store',
                                                             phone: '81981316877',
                                                             tax_id: '68005188000102',
                                                             created_at: '2021-08-10T00:00:00.000Z' } }

        schema type: :object,
               properties: {
                 store: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     name: { type: :string },
                     phone: { type: :string },
                     tax_id: { type: :string },
                     created_at: { type: :string }
                   },
                   required: %w[id name phone tax_id created_at]
                 }
               },
               required: ['store']

        let(:user) { create(:user, super: true) }
        let(:id) { create(:store).id }
        let(:authorization) { "Bearer #{jwt}" }

        run_test!
      end
    end

    put('update store') do
      tags 'Stores'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer
      parameter name: :store, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          phone: { type: :string },
          tax_id: { type: :string }
        },
        required: %w[name phone tax_id]
      }

      response(204, 'successful') do
        let(:user) { create(:user, super: true) }
        let(:id) { create(:store).id }
        let(:store) { { name: 'Fiat Store', phone: '81981316877', tax_id: '68005188000102' } }
        let(:authorization) { "Bearer #{jwt}" }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:user) { create(:user) }
        let(:authorization) { nil }
        let(:id) { create(:store).id }
        let(:store) { { name: 'Fiat Store', phone: '81981316877', tax_id: '68005188000102' } }
        run_test!
      end

      response(403, 'forbidden') do
        let(:user) { create(:user, super: false) }
        let(:id) { create(:store).id }
        let(:store) { { name: 'Fiat Store', phone: '81981316877', tax_id: '68005188000102' } }
        let(:authorization) { "Bearer #{jwt}" }
        run_test!
      end
    end

    delete('delete store') do
      tags 'Stores'
      response(204, 'successful') do
        let(:user) { create(:user, super: true) }
        let(:id) { create(:store).id }
        let(:authorization) { "Bearer #{jwt}" }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:user) { create(:user) }
        let(:authorization) { nil }
        let(:id) { create(:store).id }
        run_test!
      end

      response(403, 'forbidden') do
        let(:user) { create(:user, super: false) }
        let(:id) { create(:store).id }
        let(:authorization) { "Bearer #{jwt}" }
        run_test!
      end
    end
  end
end
