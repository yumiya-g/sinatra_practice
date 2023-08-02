# frozen_string_literal: true

require 'json'
require 'sinatra'
require 'securerandom'

before do
  @app_title = 'メモアプリ'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class MemoDB
  DB_FILE_NAME = 'db.json'

  def self.create_memo(params)
    memos = load_memos
    id = SecureRandom.uuid

    memos[id.to_sym] = { title: params['title'], content: params['content'] }
    save_memo(memos)
  end

  def self.read_memo(id)
    memos = load_memos
    memos[id.to_sym]
  end

  def self.update_memo(params)
    memos = load_memos

    memos[params['id'].to_sym] = params.slice('title', 'content')
    save_memo(memos)
  end

  def self.delete_memo(params)
    memos = load_memos

    memos.delete(params['id'].to_sym)
    save_memo(memos)
  end

  def self.save_memo(memos)
    File.open(DB_FILE_NAME, 'w') do |file|
      converted_memos = JSON.generate(memos)
      file.write(converted_memos)
    end
  end

  def self.load_memos
    file = File.open(DB_FILE_NAME, 'r')
    JSON.parse(file.read, symbolize_names: true)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = MemoDB.load_memos
  erb :index
end

get '/memos/create' do
  erb :create
end

post '/memos/new' do
  MemoDB.create_memo(@params)

  redirect '/memos'
  erb :index
end

get '/memos/:id' do
  @memo = MemoDB.read_memo(@params['id'])
  pass if @memo.nil?

  erb :show
end

get '/memos/:id/edit' do
  @memo = MemoDB.read_memo(@params['id'])

  erb :edit
end

patch '/memos/:id/edit' do
  MemoDB.update_memo(@params)

  redirect "/memos/#{@params['id']}"
  erb :show
end

get '/memos/*' do
  404
end

delete '/memos/:id/delete' do
  MemoDB.delete_memo(@params)

  redirect '/'
  erb :index
end

not_found do
  'ページが存在しません!!'
end
