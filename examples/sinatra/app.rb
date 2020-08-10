# frozen_string_literal: true

# Example Sinatra application.
class App < Sinatra::Base
  use Rack::Session::Cookie, secret: 'change_me'

  use OmniAuth::Builder do
    provider :indieauth, server: 'https://indieauth.com', client_id: 'http://example.com'
  end

  get '/' do
    <<-HTML
    <ul>
      <li><a href='/auth/indieauth'>Sign in with IndieAuth</a></li>
    </ul>
    HTML
  end

  get '/auth/:provider/callback' do
    request.env['omniauth.auth'].info.to_hash.inspect
    "<h1>Signed in!</h1>
    <pre>#{request.env['omniauth.auth'].uid}</pre>
    <pre>#{request.env['omniauth.auth'].info.to_hash.inspect}</pre>
    "
  end
end
