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

echo "=> Creating MySQL database wikidb"
mysql -uroot -e "CREATE DATABASE wikidb"
echo "=> Done!"

PASS=${MYSQL_WIKIUSER_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_WIKIUSER_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL wikiuser user with ${_word} pass. and access to wikidb"

mysql -uroot -e "CREATE USER 'wikiuser'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON wikidb.* TO 'wikiuser'@'%'"

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to wikidb using:"
echo ""
echo "    mysql -uwikiuser -p$PASS -h<host> -P<port> wikidb"
echo ""
echo "========================================================================"

echo "Installing MediaWiki in unattended mode..."
php /var/www/wiki.dv.ru/maintenance/install.php \
    --dbname wikidb \
    --dbserver localhost \
    --dbtype mysql \
    --dbuser wikiuser \
    --dbpass $PASS \
    --installdbpass $PASS \
    --installdbuser wikiuser \
    --pass 123 \
    --lang ru \
    --scriptpath "" \
    --server "http://wiki.dv.ru" \
    DentaVita admin
echo "=> Done!"

cat /LocalSettings.php.append >> /var/www/wiki.dv.ru/LocalSettings.php

php /var/www/wiki.dv.ru/maintenance/rebuildmessages.php --rebuild

mysqladmin -uroot shutdown
