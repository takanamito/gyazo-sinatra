require 'rubygems'
require 'sinatra'
require 'rack'
require 'digest/md5'
require 'sdbm'

module Gyazo
  class Controller < Sinatra::Base

    configure do
      set :dbm_path, 'db/id'
      set :image_dir, 'public/images'
      set :image_url, 'http://gyazo.localhost/images'
    end

    get '/' do
      erb :index
    end

    post '/' do
      id = request[:id]
      data = request[:imagedata][:tempfile].read
      hash = Digest::MD5.hexdigest(data).to_s
      dbm = SDBM.open(settings.dbm_path, 0644)
      dbm[hash] = id
      File.open("#{settings.image_dir}/#{hash}.png", 'w'){|f| f.write(data)}

      "#{settings.image_url}/#{hash}.png"
    end
  end
end
