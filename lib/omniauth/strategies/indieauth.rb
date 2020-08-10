# frozen_string_literal: true

require 'omniauth'
require 'faraday'
require 'faraday_middleware'
require 'indieauth_discovery/profile'
require 'cgi'

require 'omniauth/indieauth/errors'

module OmniAuth
  module Strategies
    # IndieAuth strategy for OmniAuth.
    class IndieAuth
      include OmniAuth::Strategy

      option :name, :indieauth
      option :client_id

      attr_reader :profile

      def request_phase
        authorize if valid_request_phase_params?

        profile_url_form
      end

      def callback_phase
        @profile = IndieAuthDiscovery::Profile.discover(profile_url)
        super if authenticate
      end

      uid { authentication_response.body['me'] }

      info { authentication_response.body['profile'] || {} }

      private

      attr_reader :authentication_response

      def client_id
        options.client_id || "#{request.base_url}/"
      end

      def valid_request_phase_params?
        String(request.params['me']).strip != ''
      end

      def authorize
        @profile = IndieAuthDiscovery::Profile.discover(request.params['me'])
        cache_profile_endpoints
        redirect authorization_url.to_s
      end

      def authorization_url
        authorization_endpoint_url.class.build(
          host: authorization_endpoint_url.host,
          path: authorization_endpoint_url.path,
          query: URI.encode_www_form(authorization_params)
        )
      end

      def authorization_params
        params = {
          client_id: client_id,
          redirect_uri: redirect_uri,
          me: profile_url,
          state: SecureRandom.hex(24),
          response_type: 'code'
        }
        session['omniauth.state'] = params[:state]
        params
      end

      def cache_profile_endpoints
        session['omniauth.profile_url'] = profile.url.to_s
        session['omniauth.authorization_endpoint'] = profile.authorization_endpoint
        session['omniauth.token_endpoint'] = profile.token_endpoint
      end

      def authenticate
        @authentication_response = authorization_endpoint.post('', authentication_params)
        indieauth_failure(@authentication_response, authentication_error) unless @authentication_response.status < 300
        @authentication_response
      end

      def authentication_params
        {
          client_id: client_id,
          code: request.params['code'],
          redirect_uri: redirect_uri
        }
      end

      def indieauth_failure(response, error_class)
        error_key = response.body['error']
        error_desc = response.body['error_description']
        error_uri = response.body['error_uri']
        error = error_class.new(error_desc, error_key, error_uri)
        fail!(error_key, error)
      end

      def authentication_error
        OmniAuth::IndieAuth::AuthenticationError
      end

      def profile_url_form
        form = OmniAuth::Form.new(title: 'IndieAuth Authorization')
        form.label_field('Profile URL', 'me')
        form.input_field('url', 'me')
        form.to_response
      end

      def redirect_uri
        uri = URI.parse(callback_url)
        uri.class.build(host: uri.host, path: uri.path, port: uri.port)
      end

      def profile_url
        session['omniauth.profile_url'] || profile.url.to_s
      end

      def authorization_endpoint_url
        URI.parse(session['omniauth.authorization_endpoint'] || profile.authorization_endpoint)
      end

      def authorization_endpoint
        @authorization_endpoint ||= Faraday.new(authorization_endpoint_url) do |f|
          f.request :url_encoded
          f.response :json, content_type: /\bjson\z/
          f.adapter Faraday.default_adapter
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'indieauth', 'IndieAuth'
