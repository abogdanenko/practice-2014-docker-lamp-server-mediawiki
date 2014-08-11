#!/bin/bash

function check_install_mysql()
{
    local VOLUME_HOME="/var/lib/mysql"

    if [[ ! -d $VOLUME_HOME/mysql ]]; then
        echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
        echo "=> Installing MySQL ..."
        mysql_install_db > /dev/null 2>&1
        echo "=> Done!"
        /create_mysql_admin_user.sh
    else
        echo "=> Using an existing volume of MySQL"
    fi
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
        /create_mysql_wikidb_wikiuser.sh
    else
        echo "=> Using an existing install of MediaWiki in folder $WIKI_PATH"
  fi
}

check_install_mysql
check_install_wiki

exec supervisord -n
