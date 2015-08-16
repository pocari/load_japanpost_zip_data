#/bin/bash

export KPI_MYSQL_DBNAME_DEFAULT="zip"

# 共通処理読み込み
source ./rebuild_common.sh

# DDLを実行
for i in ddl/*.sql; do
  exec_file "$i" || exit 21
done

# 正常終了
echo "Finish. No error."
exit 0

