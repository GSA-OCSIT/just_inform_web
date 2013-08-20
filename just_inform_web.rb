# web.rb
require 'bundler/setup'
Bundler.require(:default)
require 'just_inform'
require 'memcached'
require 'sinatra/base'

class JustInformWeb < Sinatra::Base
  CACHE = Memcached.new("localhost:11211")

  before do
    headers "Content-Type" => "text/html; charset=utf-8"
  end

  get '/' do
    begin
      content = CACHE.get("index")
      puts 'using cache - ' + Time.now.to_s
    rescue Memcached::NotFound
      p = JustInform::Parser.new
      @burden = p.top(25, :burden)
      @cost = p.top(25, :cost)
      @responses = p.top(25, :responses)

      content = erb(:index)
      CACHE.set("index", content, 86400)
    end

    content
  end
end