# frozen_string_literal: true

require 'omniauth/indieauth/errors'

RSpec.describe 'OmniAuth::IndieAuth Errors' do # rubocop:disable RSpec/DescribeClass
  describe OmniAuth::IndieAuth::Error do
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
