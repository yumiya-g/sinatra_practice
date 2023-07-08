# frozen_string_literal: true

require 'json'
require 'sinatra'

# 提出時に削除する
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
    @memo_ids = @memo_lists.map(&:keys).flatten
  end

  def generate_memo_lists
    @memo_lists
  end

  def create_new_memo(title, content)
    # latest_idキーからvalueを取得して、カウントをプラス１（初回投稿時には、ID1を作成）する
    @latest_memo_id = @latest_memo_id.zero? ? 1 : @latest_memo_id + 1

    # 新しいメモデータ（ハッシュ形式）を作成する
    new_memo = { @latest_memo_id => { 'title' => title, 'content' => content } }

    # 新しいメモデータを追加する
    @memos_data = @memo_lists.push new_memo

    # データを追加したhashを、JSONファイル形式に変換
    updated_memos = JSON.generate({ "latest_id": @latest_memo_id, "memo_lists": @memos_data })

    save_memo_data(updated_memos)
  end

  def show_memo_details(memo_id)
    return unless @memo_ids.include?(memo_id)

    memo = @memo_lists.map do |m|
      next unless m.keys.first == memo_id

      @title = m.values.first['title']
      @content = m.values.first['content']
      @existing_id = memo_id
      { title: @title, content: @content, existing_id: @existing_id }
    end

    memo.compact.first
  end

  def update_memo_details(params)
    return unless @memo_ids.include?(params['id'])

    # 編集されたメモデータ（ハッシュ形式）を作成する
    edited_memo = { params['id'] => { 'title' => params['title'], 'content' => params['content'] } }

    # 更新されたメモIDから、既存メモを抽出して上書きする
    updated_memo = @memo_lists.map do |m|
      m.key?(edited_memo.keys.first) ? edited_memo : m
    end

    # JSONを更新する
    updated_memos = JSON.generate({ "latest_id": @latest_memo_id, "memo_lists": updated_memo })

    save_memo_data(updated_memos)
  end

  def delete_memo(params)
    # ルーティングのIDが存在しない場合、メソッドから抜ける
    return unless @memo_ids.include?(params['id'])

    # 削除するメモのIDと、データベース内のIDが一致した場合、削除処理を実行する
    @memo_lists.delete_if do |m|
      m.key?(params['id'])
    end

    deleted_memos = JSON.generate({ "latest_id": @latest_memo_id, "memo_lists": @memo_lists })
    save_memo_data(deleted_memos)
  end

  def save_memo_data(updated_memos)
    # JSONファイルに保存する
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
  @memos = Memo.parse(DB_FILE_NAME).generate_memo_lists

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
