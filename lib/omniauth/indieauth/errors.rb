# frozen_string_literal: true

module OmniAuth
  module IndieAuth
    # Base class for OmniAuth::IndieAuth errors.
    class Error < StandardError
      attr_accessor :error, :error_reason, :error_uri

      def initialize(error, error_reason = nil, error_uri = nil)
        @error = error
        @error_reason = error_reason
        @error_uri = error_uri

        super(message)
      end

      def message
        [error, error_reason, error_uri].compact.join(' | ')
      end
    end

    # Error raised when trying to authenticate via authorization endpoint
    class AuthenticationError < Error
    end
  end
end
