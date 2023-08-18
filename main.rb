# frozen_string_literal: true

require 'json'
require 'sinatra'
require 'securerandom'
require 'pg'

# TODO:提出時に削除する
require 'sinatra/reloader'
require 'debug'

before do
  @app_title = 'メモアプリ'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class MemoDB
  MEMOS = PG::Connection.open(dbname: 'postgres')

  def self.load_memos
    MEMOS.exec('SELECT * FROM memos')
  end

  def self.create_memo(params)
    id = SecureRandom.uuid
    sql = 'INSERT INTO memos(id, title, content) VALUES ($1, $2, $3)'
    placeholders = [id, params['title'], params['content']]
    save_memo(sql, placeholders)
  end

  def self.read_memo(id)
    sql = 'SELECT * FROM memos WHERE id = $1'
    MEMOS.exec_params(sql, [id])
  end

  def self.update_memo(params)
    sql = 'UPDATE memos SET title = $1, content = $2 WHERE id = $3'
    placeholders = [params['title'], params['content'], params['id']]
    save_memo(sql, placeholders)
  end

  def self.delete_memo(params)
    sql = 'DELETE FROM memos WHERE id = $1'
    placeholders = [params['id']]
    save_memo(sql, placeholders)
  end

  def self.save_memo(sql, placeholders)
    MEMOS.exec_params(sql, placeholders)
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
  pass if @memo.nil?
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
