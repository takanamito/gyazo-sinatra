require 'rubygems'
require 'sinatra'
require 'rack'
require 'digest/md5'
require 'sdbm'
require 'dotenv'

module Gyazo
  class Controller < Sinatra::Base

    configure do
      Dotenv.load
      set :dbm_path, 'db/id'
      set :image_dir, 'public/images'
      set :image_url, "#{ENV['WEB_HOST']}/images"
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

      @url = "#{settings.image_url}/#{hash}.png"
      erb :show
    end
  end
end
