# frozen_string_literal: true

require 'json'
require 'sinatra'

# TODO: 提出時に削除する
require 'sinatra/reloader'
require 'debug'

DB_FILE_NAME = 'db.json'

before do
  @app_title = 'メモアプリ'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class Memo
  def initialize(memo_data)
    @latest_memo_id = memo_data['latest_id']
    @memo_lists = memo_data['memo_lists']
  end

  def show_memo_lists
    @memo_lists
  end

  def create_new_memo(title, content)
    @latest_memo_id += 1
    new_memo = { @latest_memo_id => { 'title' => title, 'content' => content } }
    memos_data = @memo_lists.push new_memo
    updated_memos = JSON.generate({ latest_id: @latest_memo_id, memo_lists: memos_data })

    save_memo_data(updated_memos)
  end

  def show_memo_details(memo_id)
    memo = @memo_lists.find { |list| list[memo_id] }
    { title: memo[memo_id]['title'], content: memo[memo_id]['content'] }
  end

  def update_memo_details(params)
    edited_memo = { params['id'] => { 'title' => params['title'], 'content' => params['content'] } }
    updated_memo = @memo_lists.map do |m|
      m.key?(edited_memo.keys.first) ? edited_memo : m
    end
    updated_memos = JSON.generate({ "latest_id": @latest_memo_id, "memo_lists": updated_memo })

    save_memo_data(updated_memos)
  end

  def delete_memo(params)
    @memo_lists.delete_if do |m|
      m.key?(params['id'])
    end

    deleted_memos = JSON.generate({ "latest_id": @latest_memo_id, "memo_lists": @memo_lists })
    save_memo_data(deleted_memos)
  end

  def save_memo_data(updated_memos)
    File.open(DB_FILE_NAME, 'w') do |file|
      file.write(updated_memos)
    end
  end

  def self.parse(filename)
    file = File.open(filename, 'r')
    memo_data = JSON.parse(file.read)
    Memo.new(memo_data)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = Memo.parse(DB_FILE_NAME).show_memo_lists

  erb :index
end

get '/memos/create' do
  erb :create
end

post '/memos/new' do
  Memo.parse(DB_FILE_NAME).create_new_memo(@params['title'], @params['content'])

  redirect '/memos'
  erb :index
end

get '/memos/:id' do
  @memos = Memo.parse(DB_FILE_NAME).show_memo_details(@params['id'])
  pass if @memos.nil?

  erb :show
end

get '/memos/:id/edit' do
  @memos = Memo.parse(DB_FILE_NAME).show_memo_details(@params['id'])

  erb :edit
end

patch '/memos/:id/edit' do
  @memos = Memo.parse(DB_FILE_NAME).update_memo_details(@params)

  redirect "/memos/#{@params['id']}"
  erb :show
end

get '/memos/*' do
  404
end

delete '/memos/:id/delete' do
  @memos = Memo.parse(DB_FILE_NAME).delete_memo(@params)

  redirect '/'
  erb :index
end

not_found do
  'ページが存在しません!!'
end
