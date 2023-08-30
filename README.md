# プラクティス提出

[Web アプリからの DB 利用](https://bootcamp.fjord.jp/practices/179)

## bundler の設定

1. 作業用ディレクトリを作成

作業用ディレクトリ（以下「sinatra_practice」とする）を作成して、移動します。

```
mkdir sinatra_practice
cd sinatra_practice
```

2. `bundle install`を実行する

下記コマンドを実行します。

```
bundle install
```

## データベースを作成する

1. PostgreSQL をインストール

Homebrew で PostgreSQL をインストールします。

```
brew install postgresql
```

2. PostgreSQL を起動

PostgreSQL を起動します。

```
brew services start postgresql
```

1. データベースを確認

データベースを確認します。\
今回はデータベース「postgres」を使用します。

```
psql -l
```

4. データベースにログインしてユーザーを作る

デフォルトの Mac ユーザーでログインし、任意のユーザー（スーパーユーザー）を作成します。

```sql
psql -U macのユーザ名 postgres

postgres=# create user 新規ユーザー名 with SUPERUSER;
```

新規ユーザーでログインします。

```sql
psql -U 新規ユーザー名 postgres
```

5. テーブルを作成する

データベースにログイン後、memos テーブルを作成します。

```sql
CREATE TABLE memos (
	id UUID PRIMARY KEY,
	title VARCHAR(64),
	content VARCHAR(128)
);
```

6. 作成したテーブルを確認する

memos テーブルが作成されたことを確認します。

```sql
postgres=# \d memos
```

## Sinatra を実行する

1. Sinatra を起動

ターミナルを起動して、下記コマンドで実行します。

```
bundle exec ruby main.rb
```

2. `localhost`にアクセス

Sinatra が起動できたら、ブラウザの URL 欄に「`localhost:4567`」を入力してアクセスできることを確認します。

## コードのチェック方法

1. `rubocop-fjord`を実行し、rb ファイルをチェックします。

```
rubocop
```

2. `ERB Lint`を実行し、erb ファイルをチェックします。

```
bundle exec erblint --lint-all
```

以上
