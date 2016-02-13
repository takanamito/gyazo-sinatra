require 'aws-sdk'
require 'digest/md5'
require 'dotenv'
require 'rubygems'
require 'sdbm'
require 'sinatra'

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

      send_s3("#{hash}.png", "#{settings.image_dir}")

      @url = "#{settings.image_url}/#{hash}.png"
      erb :show
    end

    private

    def send_s3(file_name, path)
      s3 = Aws::S3::Resource.new(
        region: ENV['AWS_REGION'],
        credentials:
          Aws::Credentials.new(
            ENV['AWS_ACCESS_KEY_ID'],
            ENV['AWS_SECRET_ACCESS_KEY']
          ),
      )
      obj = s3.bucket(ENV['AWS_S3_BUCKET']).object("images/#{file_name}")
      obj.upload_file("#{path}/#{file_name}")
    end
  end
end
