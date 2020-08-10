OmniAuth IndieAuth
==================

This is an OmniAuth strategy for using IndieAuth.com as an authentication server.

Basic Usage
-----------

```ruby
use OmniAuth::Builder do
  provider :indieauth, :client_id => 'http://example.com'
end
```

Using a Custom Auth Server
--------------------------

```ruby
use OmniAuth::Builder do
  provider :indieauth, :client_id => 'http://example.com', :server => 'https://indieauth.com'
end
```

Profile Info
------------

After the user signs in, the `uid` reported by OmniAuth will be their URL they entered. The gem will also attempt to parse their URL for an h-card, and return their real name and profile image if available.

```
{
  "url": "http://aaronparecki.com/",
  "name": "Aaron Parecki",
  "image": "https://aaronparecki.com/images/aaronpk.png"
}
```


Basic Sinatra Example
---------------------

```ruby
require 'bundler/setup'
require 'sinatra/base'
require 'omniauth-indieauth'

use Rack::Session::Cookie, :secret => "change_me"

use OmniAuth::Builder do
  provider :indieauth, :client_id => 'http://example.com'
end

class App < Sinatra::Base
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

run App.new
```


License
-------

```
Copyright 2020 by Aaron Parecki and contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
