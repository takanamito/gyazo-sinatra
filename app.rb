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

      today = Date.today
      local_path = "#{settings.image_dir}/#{today_path(today)}"

      FileUtils.mkdir_p(local_path) unless FileTest.exist?(local_path)
      File.open("#{local_path}/#{hash}.png", 'w'){ |f| f.write(data) }

      send_s3("#{hash}.png", local_path, "images/#{today_path(today)}")

      @url = "#{settings.image_url}/#{today_path(today)}/#{hash}.png"
      if request.user_agent == ENV['APP_UA']
        @url
      else
        erb :show
      end
    end

    private

    def today_path(today)
      "#{today.year}/#{today.month}/#{today.day}"
    end

    def send_s3(file_name, local_path, remote_path)
      s3 = Aws::S3::Resource.new(
        region: ENV['AWS_REGION'],
        credentials:
          Aws::Credentials.new(
            ENV['AWS_ACCESS_KEY_ID'],
            ENV['AWS_SECRET_ACCESS_KEY']
          ),
      )
      obj = s3.bucket(ENV['AWS_S3_BUCKET']).object("#{remote_path}/#{file_name}")
      obj.upload_file("#{local_path}/#{file_name}")
    end
  end
end
