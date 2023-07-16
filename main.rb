# frozen_string_literal: true

require 'json'
require 'sinatra'

DB_FILE_NAME = 'db.json'

before do
  @app_title = 'メモアプリ'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class MemoDB
  def self.show_memo_lists
    generate_memo_lists['memo_lists']
  end

  def self.create_new_memo(title, content)
    latest_id = generate_memo_lists['latest_id'] += 1
    memo_lists = generate_memo_lists['memo_lists']

    new_memo = { latest_id => { 'title' => title, 'content' => content } }
    updated_lists = memo_lists.push new_memo
    updated_memos = JSON.generate({ latest_id:, memo_lists: updated_lists })

    save_memo_data(updated_memos)
  end

  def self.show_memo_details(memo_id)
    memo_lists = generate_memo_lists['memo_lists']
    memo = memo_lists.find { |list| list[memo_id] }
    return nil if memo.nil?

    { title: memo[memo_id]['title'], content: memo[memo_id]['content'] }
  end

  def self.update_memo_details(params)
    latest_id = generate_memo_lists['latest_id']
    memo_lists = generate_memo_lists['memo_lists']

    edited_memo = { params['id'] => { 'title' => params['title'], 'content' => params['content'] } }
    updated_lists = memo_lists.map do |list|
      list.key?(edited_memo.keys.first) ? edited_memo : list
    end
    updated_memos = JSON.generate({ latest_id:, memo_lists: updated_lists })

    save_memo_data(updated_memos)
  end

  def self.delete_memo(params)
    latest_id = generate_memo_lists['latest_id']
    memo_lists = generate_memo_lists['memo_lists']

    memo_lists.delete_if do |list|
      list.key?(params['id'])
    end

    deleted_memos = JSON.generate({ latest_id:, memo_lists: })
    save_memo_data(deleted_memos)
  end

  def self.save_memo_data(updated_memos)
    File.open(DB_FILE_NAME, 'w') do |file|
      file.write(updated_memos)
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
  @memos = MemoDB.show_memo_lists

  erb :index
end

get '/memos/create' do
  erb :create
end

post '/memos/new' do
  MemoDB.create_new_memo(@params['title'], @params['content'])

  redirect '/memos'
  erb :index
end

get '/memos/:id' do
  @memo = MemoDB.show_memo_details(@params['id'])
  pass if @memo.nil?

  erb :show
end

get '/memos/:id/edit' do
  @memo = MemoDB.show_memo_details(@params['id'])

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
