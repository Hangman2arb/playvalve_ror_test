require 'rails_helper'
require 'httparty'

RSpec.describe 'V1::Users', type: :request do
  describe 'POST /v1/user/check_status' do
    let(:valid_headers) { { "CONTENT_TYPE" => "application/json", "CF-IPCountry" => "US" } }
    let(:valid_params) { { idfa: SecureRandom.uuid, rooted_device: false }.to_json }

    context 'when the user is not banned' do
      it 'returns not_banned status' do
        allow($redis).to receive(:smembers).and_return(['US'])
        allow(VpnApiService).to receive(:check_ip).and_return({ 'security' => { 'vpn' => false, 'proxy' => false, 'tor' => false } })

        post '/v1/user/check_status', params: valid_params, headers: valid_headers.merge("CF-IPCountry" => "US")

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['ban_status']).to eq('not_banned')
      end
    end

    context 'when the IP country is not whitelisted' do
      it 'returns banned status' do
        allow($redis).to receive(:smembers).and_return(['US'])

        post '/v1/user/check_status', params: valid_params, headers: valid_headers.merge("CF-IPCountry" => "XX")

        expect(JSON.parse(response.body)['ban_status']).to eq('banned')
      end
    end

    context 'when the device is rooted' do
      let(:rooted_params) { { idfa: SecureRandom.uuid, rooted_device: true }.to_json }

      it 'returns banned status' do
        post '/v1/user/check_status', params: rooted_params, headers: valid_headers

        expect(JSON.parse(response.body)['ban_status']).to eq('banned')
      end
    end

    context 'when the IP is identified as Tor or VPN' do
      it 'returns banned status' do
        allow(VpnApiService).to receive(:check_ip).and_return({ 'security' => { 'vpn' => true, 'proxy' => false, 'tor' => true } })

        post '/v1/user/check_status', params: valid_params, headers: valid_headers

        expect(JSON.parse(response.body)['ban_status']).to eq('banned')
      end
    end

    context 'when a new user record is created' do
      it 'creates a new user record if IDFA does not exist' do
        expect {
          post '/v1/user/check_status', params: valid_params, headers: valid_headers
        }.to change(User, :count).by(1)
      end
    end

    context 'when an existing user is checked' do
      let!(:user) { create(:user, idfa: SecureRandom.uuid, ban_status: 'unbanned') }

      it 'updates the user record if IDFA exists' do
        expect {
          post '/v1/user/check_status', params: { idfa: user.idfa, rooted_device: false }.to_json, headers: valid_headers
        }.not_to change(User, :count)
        expect(user.reload.ban_status).not_to eq('banned')
      end

      it 'returns "banned" status without re-checking if the user is already banned' do
        user.update(ban_status: 'banned')
        post '/v1/user/check_status', params: { idfa: user.idfa, rooted_device: false }.to_json, headers: valid_headers
        expect(JSON.parse(response.body)['ban_status']).to eq('banned')
      end
    end

    context 'when a new user is created' do
      it 'creates a new IntegrityLog record' do
        expect {
          post '/v1/user/check_status', params: valid_params, headers: valid_headers
        }.to change(IntegrityLog, :count).by(1)
      end
    end

    context 'when an existing user’s ban status changes' do
      let!(:user) { create(:user, idfa: SecureRandom.uuid, ban_status: 'unbanned') }

      it 'creates a new IntegrityLog record reflecting the change' do
        expect {
          post '/v1/user/check_status', params: { idfa: user.idfa, rooted_device: true }.to_json, headers: valid_headers
        }.to change(IntegrityLog, :count).by(1)
        expect(IntegrityLog.last.ban_status).to eq('banned')
      end
    end

  end
end
