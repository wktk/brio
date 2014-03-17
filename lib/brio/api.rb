module Brio

  module API

    CLIENT_ID = '9JnCd6aS5VGNjd7p5Cx6EA7qd6Xz7eEs'
    
    DEFAULT_OAUTH_HOST = 'alpha.app.net'
    DEFAULT_API_HOST = 'alpha-api.app.net'
    DEFAULT_PROTOCOL = 'https'

    REDIRECT_URI = 'https://brioapp.herokuapp.com/auth/callback/'
    SCOPE = 'stream,email,write_post,follow,messages,update_profile,export'
    RESPONSE_TYPE = 'token'


    def client_id
      config['client_id'] || CLIENT_ID
    end

    def redirect_uri
      client_id == CLIENT_ID ? REDIRECT_URI : ''
    end

    def oauth_url
      "#{protocol}://#{oauth_host}/oauth/authenticate?client_id=#{client_id}&response_type=#{RESPONSE_TYPE}&scope=#{SCOPE}&redirect_uri=#{redirect_uri}"
    end

    # POSTS
    def posts_url(id ="")
      id = "/#{id}" unless id.empty?
      "/stream/0/posts#{id}"
    end

    # USERS
    def users_url( id = "me")
      "/stream/0/users/#{id}"
    end

    private
    def base_api_url
      "#{protocol}://#{api_host}"
    end

    def oauth_host
      DEFAULT_OAUTH_HOST
    end

    def api_host
      DEFAULT_API_HOST
    end

    def protocol
      DEFAULT_PROTOCOL
    end

  end

end
