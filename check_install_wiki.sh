#!/bin/bash

function start_mysql()
{
    /usr/bin/mysqld_safe > /dev/null 2>&1 &

    RET=1
    while [[ RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of MySQL service startup"
        sleep 5
        mysql -uroot -e "status" > /dev/null 2>&1
        RET=$?
    done
}

# PASS variable is used ouside of the function
function create_mysql_wikidb_wikiuser()
{
    echo "=> Creating MySQL database wikidb"
    mysql -uroot -e "CREATE DATABASE wikidb"
    echo "=> Done!"

    PASS=${MYSQL_WIKIUSER_PASS:-$(pwgen -s 12 1)}
    local _word=$( [ ${MYSQL_WIKIUSER_PASS} ] && echo "preset" || echo "random" )
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

}

function run_install_php()
{
    local WIKI_ADMIN_PASS=$(pwgen -nc 8 1)

    echo "Running MediaWiki CLI installer ..."
    php /var/www/wiki.dv.ru/maintenance/install.php \
        --dbname wikidb \
        --dbserver localhost \
        --dbtype mysql \
        --dbuser wikiuser \
        --dbpass $PASS \
        --installdbpass $PASS \
        --installdbuser wikiuser \
        --pass $WIKI_ADMIN_PASS \
        --lang ru \
        --scriptpath "" \
        --server "http://wiki.dv.ru" \
            DentaVita admin
    echo "=> Done!"

    echo "Applying custom settings ..."
    cat /LocalSettings.php.append >> /var/www/wiki.dv.ru/LocalSettings.php
    # when $wgLanguageCode is changed, the rebuildmessages.php should be run
    php /var/www/wiki.dv.ru/maintenance/rebuildmessages.php --rebuild
    echo "=> Done!"

    echo "========================================================================"
    echo "Wiki administrator account:"
    echo ""
    echo "login: admin"
    echo "password: $WIKI_ADMIN_PASS"
    echo ""
    echo "========================================================================"
}

function check_install_wiki()
{

    local WWW_HOME="/var/www"
    local WIKI_FOLDER="wiki.dv.ru"
    local WIKI_PATH="$WWW_HOME/$WIKI_FOLDER"

    if [[ ! -d $WIKI_PATH ]]; then
        echo "=> Could not find $WIKI_FOLDER folder in $WWW_HOME"
        echo "=> New MediaWiki install"
        mkdir -v $WIKI_PATH
        echo "=> Extracting files to directory $WIKI_PATH"
        tar -xf /downloads/mediawiki.tar.gz -C $WIKI_PATH --strip 1
        chown --recursive www-data:www-data $WIKI_PATH
        echo "=> Done!"

        start_mysql
        create_mysql_wikidb_wikiuser
        run_install_php
        mysqladmin -uroot shutdown
        echo "=> Finished MediaWiki install"
    else
        echo "=> Using an existing install of MediaWiki in folder $WIKI_PATH"
  fi
}
