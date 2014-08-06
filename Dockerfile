FROM tutum/lamp:latest
MAINTAINER Alexey Bogdanenko <abogdanenko@dentavita.ru>

# Configure mysql server to use utf8 charset
ADD my1.cnf /etc/mysql/conf.d/my1.cnf

# Setup wiki.dv.ru website

# Install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-gd php5-intl

# Add Apache virtual host file
ADD wiki.dv.ru.conf /etc/apache2/sites-available/wiki.dv.ru.conf
RUN a2ensite wiki.dv.ru.conf

# Add script to create database wikidb, mysql user wikiuser
ADD create_mysql_wikidb_wikiuser.sh /create_mysql_wikidb_wikiuser.sh
RUN chmod 755 /create_mysql_wikidb_wikiuser.sh

# Download mediawiki
ADD http://releases.wikimedia.org/mediawiki/1.23/mediawiki-1.23.1.tar.gz /downloads/mediawiki.tar.gz

ADD run1.sh /run1.sh
RUN chmod 755 /run1.sh

CMD ["/run1.sh"]
