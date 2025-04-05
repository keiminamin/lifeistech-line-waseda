require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'cloudinary'
require 'json'

Cloudinary.config do |config|
  config.cloud_name = 'dsnyf00wx'
  config.api_key = '165498892554226'
  config.api_secret = '-w_qlawYRxowWYYHpxN0LZptOEg'
end

get '/' do
  erb :index
end

get '/chat' do
    name = params[:name]
    redirect "/chat/#{name}"
end

get '/chat/:name' do
    @name = params[:name]
    @chats = Chat.where(name: @name)
    erb :chat
end

post '/upload/:name' do
  if params[:file] && params[:file][:tempfile]
    begin
      upload_result = Cloudinary::Uploader.upload(params[:file][:tempfile])
      image_url = upload_result['secure_url']
      puts "Uploaded to Cloudinary: #{image_url}"

      # Chatテーブルに画像URLとメッセージを保存
      Chat.create(chat: image_url,  name: params[:name])

      # JSON形式で画像のURLをクライアントに返す
      content_type :json
      { url: image_url }.to_json
    rescue CloudinaryException => e
      puts "Cloudinary error: #{e.message}"
      status 500
      { error: 'Cloudinaryへのアップロードに失敗しました' }.to_json
    rescue ActiveRecord::ActiveRecordError => e
      puts "ActiveRecord error: #{e.message}"
      status 500
      { error: 'データベースへの保存に失敗しました' }.to_json
    rescue => e
      puts "Unexpected error: #{e.message}"
      status 500
      { error: '予期せぬエラーが発生しました' }.to_json
    end
  else
    status 400
    { error: 'ファイルが選択されていません' }.to_json
  end
end