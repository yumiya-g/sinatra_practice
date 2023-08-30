# frozen_string_literal: true

require 'json'
require 'sinatra'
require 'securerandom'
require 'pg'

before do
  @app_title = 'メモアプリ'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class MemoDB
  def initialize(connection)
    @connection = connection
  end

  def read_memos
    @connection.exec('SELECT * FROM memos')
  end

  def create_memo(params)
    id = SecureRandom.uuid
    sql = 'INSERT INTO memos(id, title, content) VALUES ($1, $2, $3)'
    placeholders = [id, params['title'], params['content']]
    save_memo(sql, placeholders)
  end

  def read_memo(id)
    memos = @connection.exec('SELECT * FROM memos')
    memos.select do |memo|
      { 'id' => memo['id'].to_s, 'title' => memo['title'].to_s, 'content' => memo['content'].to_s } if id == memo['id']
    end
  end

  def update_memo(params)
    sql = 'UPDATE memos SET title = $1, content = $2 WHERE id = $3'
    placeholders = [params['title'], params['content'], params['id']]
    save_memo(sql, placeholders)
  end

  def delete_memo(params)
    sql = 'DELETE FROM memos WHERE id = $1'
    placeholders = [params['id']]
    save_memo(sql, placeholders)
  end

  def save_memo(sql, placeholders)
    @connection.exec_params(sql, placeholders)
    @connection.exec('SELECT * FROM memos')
  end
end

connection = PG::Connection.open(dbname: 'postgres')
memo_instance = MemoDB.new(connection)

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = memo_instance.read_memos
  erb :index
end

get '/memos/create' do
  erb :create
end

post '/memos/new' do
  memo_instance.create_memo(@params)
  redirect '/memos'
  erb :index
end

get '/memos/:id' do
  @memo = memo_instance.read_memo(@params['id'])
  redirect not_found if @memo.empty?
  erb :show
end

get '/memos/:id/edit' do
  @memo = memo_instance.read_memo(@params['id'])
  erb :edit
end

patch '/memos/:id/edit' do
  memo_instance.update_memo(@params)
  redirect "/memos/#{@params['id']}"
  erb :show
end

get '/memos/*' do
  404
end

delete '/memos/:id/delete' do
  memo_instance.delete_memo(@params)
  redirect '/'
  erb :index
end

not_found do
  'メモが存在しません!!'
end
