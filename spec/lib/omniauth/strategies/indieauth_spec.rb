require 'spec_helper'

require 'omniauth/strategies/indieauth'

RSpec.describe OmniAuth::Strategies::IndieAuth do
  subject(:strategy) { described_class }

  let(:app) do
    lambda do |_env|
      [200, {}, ['Hello, World!.']]
    end
  end

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe OmniAuth::Strategies::IndieAuth::CallbackError do
    describe '#message' do
      subject(:error) { described_class.new('error', 'description', 'uri') }

      it 'includes the error' do
        expect(error.message).to match(/error/)
      end

      it 'includes the description' do
        expect(error.message).to match(/description/)
      end

      it 'includes the URI' do
        expect(error.message).to match(/uri/)
      end
    end
  end
end
