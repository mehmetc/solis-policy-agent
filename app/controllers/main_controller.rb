require 'sinatra/base'
require 'http'
require 'json'
require 'uri'
require 'cgi'
require 'lib/config_file'
require 'app/helpers/main_helper'

class MainController < Sinatra::Base
  helpers Sinatra::MainHelper

  configure do
    set :method_override, true # make a PUT, DELETE possible with the _method parameter
    set :show_exceptions, false
    set :raise_errors, false
    set :root, File.absolute_path("#{File.dirname(__FILE__)}/../../")
    set :views, (proc { "#{root}/app/views" })
    set :logging, true
    set :static, true
    set :public_folder, "#{root}/public"
  end

  get '/' do
    content_type :json

    path = request.env['HTTP_X_FORWARDED_URI'] || ''
    parsed_path = CGI.parse(URI(path).query || '')
    token = parsed_path.key?('apikey') ? parsed_path['apikey'].first : request.env['HTTP_AUTHORIZATION']&.gsub(/^bearer /i, '') || 'unknown'

    data = {
      input: {
        method: request.env['HTTP_X_FORWARDED_METHOD'],
        token: token,
        path: path,
        params: params
      }
    }

    url = "#{opa_config[:opa][:url]}#{opa_config[:opa][:policy]}"
    response = HTTP.post(url, json: data, headers: {content_type: 'application/json'})
    puts data.to_json
    puts url

    pp response.body.to_s
    if response.status == 200
      decision = JSON.parse(response.body.to_s)
      halt 403, "Not authorized" unless decision.key?('result') && decision['result']

      decision
    else
      halt 403, "Not authorized"
    end
    {}
  rescue StandardError => e
    halt 500, "Error evaluating request: #{e.message}"
  end

  get '/ping' do
    content_type :json
    {
      "api": true
    }.to_json
  end

  not_found do
    content_type :json
    message = body
    logger.error(message)
    message.to_json
  end

  error do
    content_type :json
    message = { status: 500, body: "error:  #{env['sinatra.error'].to_s}" }
    logger.error(message)
    message.to_json
  end
end