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

## Sinatraを実行する
1. Sinatraを起動

ターミナルを起動して、下記コマンドを実行します。

```
ruby main.rb
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
