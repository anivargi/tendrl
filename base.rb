require 'tendrl'

class Base < Sinatra::Base
  set :root, File.dirname(__FILE__)

  set :environment, ENV['RACK_ENV'] || 'development'

  configure :development, :test do
    set :etcd_config, Proc.new {
      YAML.load_file('config/etcd.yml')[settings.environment.to_sym] 
    }
  end

  configure :production do
    set :etcd_config, Proc.new {
      if File.exists?('/etc/tendrl/etcd.yml')
        YAML.load_file('/etc/tendrl/etcd.yml')[settings.environment.to_sym] 
      else
        YAML.load_file('config/etcd.yml')[settings.environment.to_sym] 
      end
    }
  end

  set :http_allow_methods, [
    'POST',
    'GET',
    'OPTIONS',
    'PUT',
    'DELETE'
  ]

  set :http_allow_headers, [
    'Origin',
    'Content-Type',
    'Accept',
    'Authorization',
    'X-Requested-With'
  ]

  set :http_allow_origin, [
    '*'
  ]

  set :etcd, Proc.new {
    Etcd.client(
      host: etcd_config[:host],
      port: etcd_config[:port],
      user_name: etcd_config[:user_name],
      password: etcd_config[:password]
    )
  }

  before do
    content_type :json
    response.headers["Access-Control-Allow-Origin"] = 
      settings.http_allow_origin.join(',')
    response.headers["Access-Control-Allow-Methods"] = 
      settings.http_allow_methods.join(',')
    response.headers["Access-Control-Allow-Headers"] = 
      settings.http_allow_headers.join(',')
  end

  get '/ping' do
    { 
      status: 'Ok'
    }.to_json
  end

  get '/GetJobList' do

  end

  protected

  def etcd
    settings.etcd
  end

end
