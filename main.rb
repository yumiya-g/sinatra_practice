# frozen_string_literal: true

require 'json'
require 'sinatra'

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
  DB_FILE_NAME = 'db.json'

  def self.read_memos
    generate_memo_lists['memo_lists']
  end

  def self.create_memo(title, content)
    memos = generate_memo_lists
    latest_id = memos['latest_id'] + 1
    memo_lists = memos['memo_lists']

    new_memo = { 'title' => title, 'content' => content }
    memos['memo_lists'][latest_id] = new_memo
    save_memo_data(latest_id, memo_lists)
  end

  def self.read_memo(memo_id)
    memos = generate_memo_lists['memo_lists']
    memos[memo_id]
  end

  def self.update_memo_details(params)
    memos = generate_memo_lists
    latest_id = memos['latest_id']
    memo_lists = memos['memo_lists']
    
    memo_lists[params['id']] = params.slice(:title, :content)
    save_memo_data(latest_id, memo_lists)
  end

  def self.delete_memo(params)
    memos = generate_memo_lists
    latest_id = memos['latest_id']
    memo_lists = memos['memo_lists']

    memo_lists.delete(params['id'])
    save_memo_data(latest_id, memo_lists)
  end

  def self.save_memo_data(latest_id, memo_lists)
    File.open(DB_FILE_NAME, 'w') do |file|
      converted_memos = JSON.generate({ latest_id:, memo_lists: })
      file.write(converted_memos)
    end
  end

  def self.generate_memo_lists
    file = File.open(DB_FILE_NAME, 'r')
    JSON.parse(file.read)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = MemoDB.read_memos

  erb :index
end

get '/memos/create' do
  erb :create
end

post '/memos/new' do
  MemoDB.create_memo(@params['title'], @params['content'])

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
  MemoDB.update_memo_details(@params)

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
