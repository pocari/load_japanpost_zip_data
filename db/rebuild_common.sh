#/bin/bash

if [ "$__REBUILD_COMMON_INCLUDED__" != 1 ]; then  # <include_guard>
export __REBUILD_COMMON_INCLUDED__=1


function getenv() {
	if [ "$1" == "" ]; then
		echo $2
	else
		echo $1
	fi
}

export MYSQL_HOST=`getenv "$KPI_MYSQL_HOST" localhost`
export MYSQL_PORT=`getenv "$KPI_MYSQL_PORT" 3306`
export MYSQL_USER=`getenv "$KPI_MYSQL_USER" zip_user`
export MYSQL_PASSWD=`getenv "$KPI_MYSQL_PASSWD" -zip_user-`
export MYSQL_ROOTPASSWD=`getenv "$KPI_MYSQL_ROOTPASSWD" -root-`
export MYSQL_DBNAME=`getenv "$KPI_MYSQL_DBNAME" "$KPI_MYSQL_DBNAME_DEFAULT"`
export MYSQL_OPTION=(--local-infile --init-command="set foreign_key_checks=0" `getenv "$KPI_MYSQL_OPTION" ""`)

echo "MYSQL_HOST      : $MYSQL_HOST"
echo "MYSQL_PORT      : $MYSQL_PORT"
echo "MYSQL_USER      : $MYSQL_USER"
echo "MYSQL_PASSWD    : $MYSQL_PASSWD"
echo "MYSQL_DBNAME    : $MYSQL_DBNAME"
echo "MYSQL_OPTION    :" "${MYSQL_OPTION[@]}"
echo "MYSQL_ROOTPASSWD: $MYSQL_ROOTPASSWD"

read -n1 -p 'OK ? [y/N]' KEY_IN
echo
if [ "$KEY_IN" != "Y" -a "$KEY_IN" != "y" ]; then
	echo "canceled."
	exit 1
fi

pushd `dirname $0`

if [ `uname` = "Darwin" ]; then
  ZCAT_CMD="gzcat"
elif [ `uname` = "Linux" ]; then
  ZCAT_CMD="zcat"
fi


# MySQLのroot権限でSQL文を実行する関数
function exec_sql_as_dba() {
    echo "exec '$1'"
	echo "$1" | mysql "${MYSQL_OPTION[@]}" $2 -h$MYSQL_HOST -P$MYSQL_PORT -u root -p$MYSQL_ROOTPASSWD
	if [ $? != 0 ]; then
		echo "ERROR: Can't exec sql '$1'."
		return 1
	fi
	return 0
}

# rootとしてSQLファイルを実行する関数
function exec_file_as_dba() {
    echo "exec file '$1'..."
	mysql "${MYSQL_OPTION[@]}" -h$MYSQL_HOST $2 -P$MYSQL_PORT -u root -p$MYSQL_ROOTPASSWD  < $1
	if [ $? != 0 ]; then
		echo "ERROR: Can't exec file '$1' as SQL."
		return 1
	fi
	return 0
}

# SQL形式のファイルを実行する関数
function exec_file() {
    echo "exec file '$1'..."
	#echo mysql "${MYSQL_OPTION[@]}" -h$MYSQL_HOST $2 -P$MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWD $MYSQL_DBNAME
	mysql "${MYSQL_OPTION[@]}" -h$MYSQL_HOST $2 -P$MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWD $MYSQL_DBNAME < $1
	if [ $? != 0 ]; then
		echo "ERROR: Can't exec file '$1' as SQL."
		return 1
	fi
	return 0
}

# 単純なSQL形式のファイルをロードする関数
function import_file() {
    echo "importing '$1'..."
	mysqlimport -L $2 -h$MYSQL_HOST -P$MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWD $MYSQL_DBNAME $1
	if [ $? != 0 ]; then
		echo "ERROR: Can't import from '$1' as SQL."
		return 1
	fi
	return 0
}

# gzip形式の圧縮ファイルをロードする関数
function exec_gzip_file() {
    echo "exec file '$1'..."
	${ZCAT_CMD} $1 | mysql "${MYSQL_OPTION[@]}" $2 -h$MYSQL_HOST -P$MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWD $MYSQL_DBNAME
	if [ ${PIPESTATUS[0]} != 0 -o ${PIPESTATUS[1]} != 0 ]; then
		echo "ERROR: Can't exec file '$1' via gzip as SQL."
		return 1
	fi
	return 0
}

fi  # </include guard>

