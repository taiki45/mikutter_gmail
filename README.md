# Play with gmail via mikutter
mikutter で上司や教授にメールを送ろう！

## Setup
`git clone` した後にこのディレクトリに`config.yaml`という名前で設定ファイルを置いてください。
`sample.yaml` を参考に自分の Gmail アカウント名とパスワードをかいてください。

`gmail` という Gem が必要です。

```sh
gem i gmail
```

とするか、`your/mikutter/dir/Gemfile` に
```ruby
gem 'gmail'
```
として`bundle` 後に `bundle exec ruby mikutter.rb` として起動してください。

## Usage
mikutter のポストボックスで
```
@mail
to:mail@example.com
subject:sample subject
ここに本文☆
いろいろかいてね。
```
という感じの形式でポストしてください。

もし形式を間違っても`@mail`むけのポストは投稿しないです。
でもクリティカルなメールは避けてね！

おまけとして控えめな未読メール数通知もございます。

## Plan
* まずはエンコード関係でエラーでているのでその fix
* unread メッセージも読めるといいなとか

## Contributing
バグリポット、ようぼう、プルリックエストを歓迎します。
