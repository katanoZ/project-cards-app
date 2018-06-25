# project cards app  
（カード型プロジェクト＆タスク管理アプリ）  
https://project-cards-app.herokuapp.com/

![アプリ画像](https://user-images.githubusercontent.com/3204814/41578465-78282cda-73cd-11e8-8ae0-91c292aaecbd.png)

![アプリ画像](https://user-images.githubusercontent.com/3204814/41578288-766159ea-73cc-11e8-8eb3-f4548be78b8a.png)

## 概要
プロジェクトごとにタスクを管理できるwebアプリケーションです。  
複数のユーザで使用する事を想定しています。プロジェクトの中にカードの形で複数のタスクを作成して、カードを自由に並べて管理することができます。カードには担当者や期限の設定ができます。

## 環境
* Ruby 2.5.0  
* Rails 5.1.5  
* DB PostgreSQL 10.3
* Webpacker 3.2.1
* Bootstrap 4.0.0
* Rspec 3.7
* Heroku （Cloudinaryアドオン使用）

## 機能
* sns認証
* ユーザ作成、退会処理、マイページ画像アップロード
* プロジェクト、カラム、カードのCRUD処理
* カラム、カードの移動機能
* ユーザ招待、参加、お知らせ機能
* ログ機能

## 権限について
プロジェクトのホスト（プロジェクトを作成したユーザ）と参加者（招待されたユーザ）で実行可能な操作が異なります。  

プロジェクトのホストは以下の操作が可能です  
- プロジェクトの詳細表示・編集・削除、他のユーザの招待  
- カラムとカードの作成・編集・移動・削除  

プロジェクトの参加者は以下の操作が可能です  
- プロジェクトの詳細表示  
- カラムとカードの作成・編集・移動・削除  

## ユーザ退会時の処理について
退会するユーザがホストをしているプロジェクトがある場合、そのプロジェクトに参加者がいれば、一番古い参加者が代わってプロジェクトのホストになります。プロジェクトに参加者がいない場合は、プロジェクトは削除されます。

## ER図
![ER図](https://user-images.githubusercontent.com/3204814/41639414-a341470a-7498-11e8-9758-edd8cf64e4e8.png)

## 実行方法
1. リポジトリをローカルにクローン  
```
git clone git@github.com:katanoZ/project-cards-app.git
```

2. 必要なGemをインストール  
```
bundle install
```

3. データベースを設定  
```
rails db:migrate
```

4. アプリの起動  
```
bundle exec foreman start
```
上記コマンドで起動。（ポートはデフォルトで5000）  
railsとwebpackerのプロセスが同時に立ち上がります。
