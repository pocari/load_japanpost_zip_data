DROP TABLE IF EXISTS tmp_mst_zip;
CREATE TABLE mst_zip (
  id                      int          NOT NULL AUTO_INCREMENT COMMENT 'ID',
  code                    varchar(5)                           COMMENT '全国地方公共団体コード',
  old_zip_code            varchar(5)                           COMMENT '旧郵便番号',
  zip_code                varchar(7)                           COMMENT '郵便番号',
  todofuken_kana          varchar(7)                           COMMENT '都道府県名カナ',
  shikuchoson_kana        varchar(24)                          COMMENT '市区町村名カナ',
  choiki_kana             varchar(512)                         COMMENT '町域名カナ',
  todofuken               varchar(4)                           COMMENT '都道府県名',
  shikuchoson             varchar(10)                          COMMENT '市区町村名',
  choiki                  varchar(512)                         COMMENT '町域名',
  flg_choiki_tokutei_fuka varchar(1)                           COMMENT '町域特定不可フラグ',
  flg_koaza_tyoufuku      varchar(1)                           COMMENT '小字重複フラグ',
  flg_tyome_ari           varchar(1)                           COMMENT '丁目ありフラグ',
  flg_choiki_tyoufuku     varchar(1)                           COMMENT '町域重複フラグ',
  flg_update              varchar(1)                           COMMENT '更新フラグ',
  flg_update_reason       varchar(1)                           COMMENT '変更理由フラグ',
  primary key (id)
);

