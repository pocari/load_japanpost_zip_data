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

- テスト

```
$ bundle exec rspec spec/**/*_spec.rb
```

- データベース構築

```
$ cd db
$ bash rebuild_db.sh
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

- 参考

```SQL
-- 要確認住所
select
  * 
from
  mst_zip
where
  zip_code in (
    '0720819', -- 単純に同一郵便番号に2つの町域が割あたっているケース（連結されない)
    '1620836', -- 一つの郵便番号に一つのデータのみが割あたっているケース（ノーマルケース）
    '6028368', -- 町域カナは同じ値だが、町域は複数レコード分連結が必要な住所
    '8260043'  -- 町域、町域カナともに連結が必要な住所
  )
order by
  zip_code, id
```

