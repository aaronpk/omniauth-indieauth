# frozen_string_literal: true

require 'omniauth'
require 'faraday'
require 'cgi'

module OmniAuth
  module Strategies
    # IndieAuth strategy for OmniAuth.
    class IndieAuth
      include OmniAuth::Strategy

      option :name, 'indieauth'
      option :server, 'https://indieauth.com'
      option :client_id

      attr_accessor :me

      def redirect_uri
        full_host + script_name + callback_path
      end

      def request_phase
        puts redirect_uri
        redirect "#{options.server}/sign-in?redirect_uri=#{URI.encode_www_form_component(redirect_uri)}&client_id=#{URI.encode_www_form_component(options.client_id)}"
      end

      def callback_phase
        puts request.params.inspect

        conn = Faraday.new(url: "#{options.server}/auth") do |faraday|
          faraday.request :url_encoded # form-encode POST params
        end
        response = Faraday.post "#{options.server}/auth", {
          code: request.params['code'],
          client_id: options.client_id,
          redirect_uri: redirect_uri
        }
        puts response.body

        data = CGI.parse response.body

        if !data['me'].empty?
          @me = data['me'][0]
        else
          fail!(data['error'][0].to_sym, CallbackError.new(data['error'][0].to_sym, data['error_description'][0]))
        end

        super
      end

      uid do
        @me
      end

      info do
        # TODO: Parse the url and look for an h-card to fill out the profile info

        {
          url: @me
        }
      end

      class CallbackError < StandardError
        attr_accessor :error, :error_reason, :error_uri

        def initialize(error, error_reason = nil, error_uri = nil)
          self.error = error
          self.error_reason = error_reason
          self.error_uri = error_uri
        end

        def message
          [error, error_reason, error_uri].compact.join(' | ')
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'indieauth', 'IndieAuth'
