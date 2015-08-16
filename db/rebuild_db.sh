#/bin/bash
export KPI_MYSQL_DBNAME_DEFAULT="zip"
source ./rebuild_common.sh

# DROP DATABASE する
exec_sql_as_dba "DROP DATABASE $MYSQL_DBNAME;" '-f' || exit 11
exec_sql_as_dba "DROP USER $MYSQL_USER;" '-f' || exit 12

# ユーザ作成
exec_sql_as_dba "CREATE USER ${MYSQL_USER} IDENTIFIED BY '${MYSQL_PASSWD}';" || exit 13
# データベース作成
exec_sql_as_dba "CREATE DATABASE ${MYSQL_DBNAME} DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" || exit 14
# 権限付与
exec_sql_as_dba "GRANT ALL PRIVILEGES ON ${MYSQL_DBNAME}.* TO ${MYSQL_USER}@localhost IDENTIFIED BY '${MYSQL_PASSWD}';" || exit 15
exec_sql_as_dba "GRANT ALL PRIVILEGES ON ${MYSQL_DBNAME}.* TO ${MYSQL_USER}@'192.168.%' IDENTIFIED BY '${MYSQL_PASSWD}';" || exit 16
exec_sql_as_dba "GRANT FILE ON *.* to '${MYSQL_USER}'@'192.168.%';" || exit 17

# DDLを実行
source ./rebuild_all_tables.sh

# 正常終了
exit 0
