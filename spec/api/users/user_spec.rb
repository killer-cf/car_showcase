require 'rails_helper'

describe 'User' do
  it 'POST /api/v1/users' do
    post '/api/v1/users', params: { user: { name: 'John Doe', tax_id: '123.456.789-00' } }

    expect(response).to have_http_status(:created)
    expect(response.content_type).to include 'application/json'
    json_response = JSON.parse(response.body)
    expect(json_response['name']).to include('John Doe')
    expect(json_response['tax_id']).to include('123.456.789-00')
  end
end
