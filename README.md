# プラクティス提出
[Sinatra を使ってWebアプリケーションの基本を理解する](https://bootcamp.fjord.jp/practices/157)


## bundlerの設定
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
1. PostgreSQLをインストール

HomebrewでPostgreSQLをインストールします。

```
brew install postgresql
```

2. PostgreSQLを起動

PostgreSQLを起動します。
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

デフォルトのMacユーザーでログインし、任意のユーザー（スーパーユーザー）を作成します。
```sql
psql -U macのユーザ名 postgres

postgres=# create user 新規ユーザー名 with SUPERUSER;
```

新規ユーザーでログインします。
```sql
psql -U 新規ユーザー名 postgres 
```

5. テーブルを作成する

データベースにログイン後、memosテーブルを作成します。

```sql
CREATE TABLE memos (
	id UUID PRIMARY KEY,
	title VARCHAR(64),
	content VARCHAR(128)
);
```

6. 作成したテーブルを確認する

memosテーブルが作成されたことを確認します。

```sql
postgres=# \d memos
```


## Sinatraを実行する
1. Sinatraを起動

ターミナルを起動して、下記コマンドで実行します。

```
bundle exec ruby main.rb
```

2. `localhost`にアクセス
   
Sinatraが起動できたら、ブラウザのURL欄に「`localhost:4567`」を入力してアクセスできることを確認します。

## コードのチェック方法
1. `rubocop-fjord`を実行し、rbファイルをチェックします。

```
rubocop
```

2. `ERB Lint`を実行し、erbファイルをチェックします。

```
bundle exec erblint --lint-all
```

以上
