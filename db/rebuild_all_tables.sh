#/bin/bash

export KPI_MYSQL_DBNAME_DEFAULT="yn_test"

# 共通処理読み込み
source ./rebuild_common.sh

# DDLを実行
for i in ddl/*.sql; do
  exec_file "$i" || exit 21
done

## ビュー作成
#exec_file "create_view.sql" || exit 31

# # コードマスタ投入
# exec_file "replace_codemaster.sql" || exit 51

# 正常終了
echo "Finish. No error."
exit 0

