#郵政省の郵便番号データロード

##環境
- ruby 2.2.2
- bundler 1.10.5
- mysql 5.6.25

##セットアップ

- 依存ライブラリ

```
$ bundle install
```

- データベース構築

```
$ cd db
$ bash rebuild_db.sh
```

- テスト

```
$ cd ${project_root}
$ bundle exec rspec spec/**/*_spec.rb
```

##実行
### データ取得
[郵政省の郵便番号データダウンロードページ](http://www.post.japanpost.jp/zipcode/dl/kogaki-zip.html)から全国分をダウンロードして展開(ここでは促音・拗音小書きの方）

```
$ cd ${project_root}
$ wget http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip
$ unzip ken_all.zip
```

###データロード

```
$ bundle exec ruby load_csv.rb
```

##確認

```
$ echo 'select count(*) from mst_zip' | mysql -hlocalhost -uzip_user -p'-zip_user-' zip
# => count(*)
# => 123719
```

