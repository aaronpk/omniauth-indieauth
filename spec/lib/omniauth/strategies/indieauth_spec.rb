# frozen_string_literal: true

require 'spec_helper'

require 'cgi'
require 'sinatra'

require 'omniauth/strategies/indieauth'

RSpec.describe OmniAuth::Strategies::IndieAuth do
  let(:app) do
    strategy = described_class
    Class.new(Sinatra::Base) do
      use Rack::Session::Cookie, secret: 'foobar'
      use strategy, client_id: 'https://client.example/'

      disable :show_exceptions
      enable :raise_errors
    end
  end

  let(:session) { last_request.env['rack.session'] }

  let(:profile_body) { File.read(File.expand_path('../../../support/fixtures/profile.html', __dir__)) }

  before do
    OmniAuth.config.logger = Logger.new('/dev/null')
    OmniAuth.config.on_failure = ->(env) { raise env['omniauth.error'] }
  end

  describe '/auth/indieauth with a valid profile URL' do
    let(:redirect_location) { last_response.location }
    let(:redirect_params) { CGI.parse(URI.parse(redirect_location).query).transform_values(&:first) }

    before do
      stub_request(:head, 'https://example.org/').to_return(status: 204)
      stub_request(:get, 'https://example.org/')
        .to_return(status: 200, body: profile_body, headers: { 'Content-Type': 'text/html' })

      get '/auth/indieauth?me=https://example.org'
    end

    it 'redirects to the authorization endpoint' do
      expect(redirect_location.to_s).to match(%r{\Ahttps://example.org/auth})
    end

    it 'sets the client ID' do
      expect(redirect_params['client_id']).to eq('https://client.example/')
    end

    it 'sets the profile URL' do
      expect(redirect_params['me']).to eq('https://example.org/')
    end

    it 'sets the redirect URI' do
      expect(redirect_params['redirect_uri']).to match(%r{/auth/indieauth/callback})
    end

    it 'sets the state' do
      expect(redirect_params['state'].length).to eq(48)
    end

    it 'stores the state in the session' do
      expect(session['omniauth.state']).to eq(redirect_params['state'])
    end
  end

  describe '/auth/indieauth with no client_id configured' do
    let(:redirect_location) { last_response.location }
    let(:redirect_params) { CGI.parse(URI.parse(redirect_location).query).transform_values(&:first) }

    let(:app) do
      strategy = described_class
      Class.new(Sinatra::Base) do
        use Rack::Session::Cookie, secret: 'foobar'
        use strategy

        disable :show_exceptions
        enable :raise_errors
      end
    end

    before do
      stub_request(:head, 'https://user.example/').to_return(status: 204)
      stub_request(:get, 'https://user.example/')
        .to_return(status: 200, body: profile_body, headers: { 'Content-Type': 'text/html' })

      get '/auth/indieauth?me=https://user.example'
    end

    it 'sets the client ID from the base URL of the request' do
      # Default request base URL is example.org when running tests.
      expect(redirect_params['client_id']).to eq('http://example.org/')
    end
  end

  describe '/auth/indieauth without a profile URL' do
    before { get '/auth/indieauth' }

    it 'returns HTTP success' do
      expect(last_response).to be_ok
    end

    it 'returns HTML' do
      expect(last_response.content_type).to eq('text/html')
    end

    it 'renders a profile URL input' do
      expect(last_response.body).to match(/<input[^>]*me/)
    end
  end

  describe '/auth/indieauth/callback with a valid authorization code' do
    let(:auth_body) do
      {
        me: 'https://example.org/',
        profile: {
          type: 'card',
          name: 'Aaron Parecki',
          url: 'https://aaronparecki.com/',
          photo: 'https://aaronparecki.com/images/profile.jpg'
        }
      }
    end

    before do
      stub_request(:head, 'https://example.org/').to_return(status: 204)
      stub_request(:get, 'https://example.org/')
        .to_return(status: 200, body: profile_body, headers: { 'Content-Type': 'text/html' })
      stub_request(:post, 'https://example.org/auth')
        .to_return(status: 200, body: auth_body.to_json, headers: { 'Content-Type': 'application/json' })

      get '/auth/indieauth?me=https://example.org'

      post '/auth/indieauth/callback', { 'code' => 'valid-authorization-code', 'me' => 'https://example.org/' }
    end

    it 'sets an auth hash' do
      expect(last_request.env['omniauth.auth']).to be_kind_of(Hash)
    end

    it 'sets the UID' do
      expect(last_request.env['omniauth.auth']['uid']).to eq('https://example.org/')
    end
  end

  describe '/auth/indieauth/callback with an invalid authorization code' do
    let(:auth_body) { { error: 'invalid_request' } }

    before do
      stub_request(:head, 'https://example.org/').to_return(status: 204)
      stub_request(:get, 'https://example.org/')
        .to_return(status: 200, body: profile_body, headers: { 'Content-Type': 'text/html' })
      stub_request(:post, 'https://example.org/auth')
        .to_return(status: 400, body: auth_body.to_json, headers: { 'Content-Type': 'application/json' })

      get '/auth/indieauth?me=https://example.org'
    end

    it 'raises an authentication' do
      expect do
        post '/auth/indieauth/callback', { 'code' => 'invalid-authorization-code', 'me' => 'https://example.org/' }
      end.to raise_error(OmniAuth::IndieAuth::AuthenticationError)
    end
  end
end
