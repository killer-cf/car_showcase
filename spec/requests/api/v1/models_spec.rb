require 'swagger_helper'

RSpec.describe 'api/v1/models' do
  let(:user) { create(:user, role: :super) }
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

  path '/api/v1/models' do
    get('list models') do
      tags 'Models'
      produces 'application/json', 'application/xml'
      response(200, 'successful') do
        example 'application/json', :example_key, { models: [{ id: 'ddf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                               name: 'Mustang',
                                                               brand_id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                               created_at: '2021-08-10T00:00:00.000Z',
                                                               updated_at: '2021-08-10T00:00:00.000Z' },
                                                             { id: 'tff9cfdc-b795-45af-9f44-4f017ab105c3',
                                                               name: 'Maverick',
                                                               brand_id: 'kkf9cfdc-b795-45af-9f44-4f017ab105c3',
                                                               created_at: '2021-08-10T00:00:00.000Z',
                                                               updated_at: '2021-08-10T00:00:00.000Z' }],
                                                    meta: { current_page: 2,
                                                            next_page: 3,
                                                            prev_page: 1,
                                                            total_pages: 10,
                                                            total_count: 20 } }

        run_test!
      end
    end

    post 'Creates a model' do
      tags 'Models'
      consumes 'application/json'
      parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'
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
        let(:authorization) { "Bearer #{jwt}" }

        let(:brand_id) { create(:brand).id }
        let(:model) { { name: 'foo', brand_id: } }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:authorization) { nil }
        let(:brand_id) { create(:brand).id }
        let(:model) { { name: 'foo', brand_id: } }
        run_test!
      end

      response(403, 'forbidden') do
        let(:user) { create(:user) }
        let(:authorization) { "Bearer #{jwt}" }
        let(:brand_id) { create(:brand).id }
        let(:model) { { name: 'foo', brand_id: } }
        run_test!
      end
    end
  end

  path '/api/v1/models/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    delete('delete model') do
      tags 'Models'
      response(204, 'successful') do
        let(:authorization) { "Bearer #{jwt}" }

        let(:brand_id) { create(:brand).id }
        let(:id) { create(:model, brand_id:).id }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:authorization) { nil }
        let(:brand_id) { create(:brand).id }
        let(:id) { create(:model, brand_id:).id }
        run_test!
      end

      response(403, 'forbidden') do
        let(:user) { create(:user) }
        let(:brand_id) { create(:brand).id }
        let(:id) { create(:model, brand_id:).id }
        let(:authorization) { "Bearer #{jwt}" }
        run_test!
      end
    end
  end
end
