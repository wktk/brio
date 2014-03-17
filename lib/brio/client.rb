require 'faraday_middleware'
#require 'json'
require 'brio/resources/post.rb'

module Brio

  class Client
    include API

    HTTP_VERBS = { 
      create: 'post', 
      delete: 'delete', 
      get: 'get' 
    }

    METHOD_PATTERNS = {
      users: /(.*)_user(_?(.*))/,
      posts: /(.*)_post(_?(.*))/
    }

    def initialize
      @conn = Faraday.new( :url => base_api_url ) do |faraday|
        faraday.request  :json
        faraday.response :json, :content_type => /\bjson$/
        faraday.adapter  Faraday.default_adapter
      end
      @rc = RCFile.instance
      add_oauth_header unless @rc.empty?
    end

    def config
      @rc
    end

    def method_missing(method_name, *args, &block)
      case 
      when method_name.to_s =~ METHOD_PATTERNS[:users]
        users HTTP_VERBS[$1.to_sym], args, $3.gsub(/_/, '/')
      when method_name.to_s =~ METHOD_PATTERNS[:posts]
        posts HTTP_VERBS[$1.to_sym], args, $3.gsub(/_/, '/')
      else
        super
      end 
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s =~ METHOD_PATTERNS[:users] ||
      method_name.to_s =~ METHOD_PATTERNS[:posts]
    end


    private 
    def add_oauth_header
      @conn.authorization :bearer, config['token'] unless config['token'].to_s.empty?
    end

    # USERS
    def users( verb, args, to_append='')
      username = get_id_from_args args
      username = 'me' if username.empty?
      params_hash = get_params_from_args args
      r = @conn.method(verb).call do |req|
        req.url "#{users_url username}/#{to_append}"
        req.params = params_hash
      end
      case to_append
      when 'mentions', 'stars', 'posts'
        Resources::Post.create_from_json r.body
      else
        Resources::User.create_from_json r.body
      end
    end

    #POSTS
    def posts( verb, args, to_append='')
      id = get_id_from_args args
      params_hash = get_params_from_args args
      r = @conn.method(verb).call do |req|
        req.url "#{posts_url id}/#{to_append}"
        if verb.to_s == 'get'
          req.params = params_hash
        else
          req.body = params_hash
        end
      end
      case to_append
      when 'reposters', 'stars'
        Resources::User.create_from_json r.body
      else
        Resources::Post.create_from_json r.body
      end
    end

    def get_id_from_args( args )
      if args.first && args.first.is_a?(String)
        args.first 
      else 
        "" 
      end
    end

    def get_params_from_args( args )
      if args.last && args.last.is_a?(Hash)
        args.last 
      else 
        {} 
      end
    end

  end

end
