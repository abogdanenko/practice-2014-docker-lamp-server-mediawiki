#!/bin/bash

# Adapted from https://github.com/tutumcloud/tutum-docker-lamp/raw/8ca614ad93e39274dc586e053287a14d5faff656/create_mysql_admin_user.sh

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

PASS=${MYSQL_WIKIUSER_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_WIKIUSER_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"

mysql -uroot -e "CREATE DATABASE wikidb"
mysql -uroot -e "CREATE USER 'wikiuser'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON wikidb.* TO 'wikiuser'@'%'"


echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uwikiuser -p$PASS -h<host> -P<port>"
echo ""
echo "========================================================================"

mysqladmin -uroot shutdown
