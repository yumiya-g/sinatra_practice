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

    new_memo = { latest_id => { 'title' => title, 'content' => content } }
    memo_lists.push new_memo

    changed_memos = { latest_id:, memo_lists: }
    save_memo_data(changed_memos)
  end

  def self.read_memo(memo_id)
    memos = generate_memo_lists['memo_lists']
    # TODO: メモIDとハッシュのキーで照合する
    memo = memos.find { |list| list[memo_id] }
    return nil if memo.nil?

    { title: memo[memo_id]['title'], content: memo[memo_id]['content'] }
  end

  def self.update_memo_details(params)
    memos = generate_memo_lists
    latest_id = memos['latest_id']
    memo_lists = memos['memo_lists']

    edited_memo = { params['id'] => { 'title' => params['title'], 'content' => params['content'] } }
    updated_lists = memo_lists.map do |list|
      list.key?(edited_memo.keys.first) ? edited_memo : list
    end

    changed_memos = { latest_id:, memo_lists: updated_lists }
    save_memo_data(changed_memos)
  end

  def self.delete_memo(params)
    memos = generate_memo_lists
    latest_id = memos['latest_id']
    memo_lists = memos['memo_lists']

    memo_lists.delete_if do |list|
      list.key?(params['id'])
    end

    changed_memos = { latest_id:, memo_lists: }
    save_memo_data(changed_memos)
  end

  def self.save_memo_data(changed_memos)
    converted_memos = JSON.generate(changed_memos)

    File.open(DB_FILE_NAME, 'w') do |file|
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
