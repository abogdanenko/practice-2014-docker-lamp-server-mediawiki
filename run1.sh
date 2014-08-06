#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_admin_user.sh
    /create_mysql_wikidb_wikiuser.sh
else
    echo "=> Using an existing volume of MySQL"
fi

WWW_HOME="/var/www"
WIKI_FOLDER="wiki.dv.ru"
WIKI_PATH="$WWW_HOME/$WIKI_FOLDER"

if [[ ! -d $WIKI_PATH ]]; then
    echo "=> Could not find $WIKI_FOLDER folder in $WWW_HOME"
    echo "=> Installing MediaWiki ..."
    mkdir -v $WIKI_PATH
    tar -xf /downloads/mediawiki.tar.gz -C $WIKI_PATH --strip 1
    echo "=> Done!"
else
    echo "=> Using an existing folder $WIKI_PATH"
fi

exec supervisord -n
