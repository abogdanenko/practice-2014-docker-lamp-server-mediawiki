FROM tutum/lamp:latest
MAINTAINER Alexey Bogdanenko <abogdanenko@dentavita.ru>

# Install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-gd php5-intl

# Add Apache virtual host file for website wiki.dv.ru
ADD wiki.dv.ru.conf /etc/apache2/sites-available/wiki.dv.ru.conf
RUN a2ensite wiki.dv.ru.conf

# Configure mysql server to use utf8 charset
ADD my1.cnf /etc/mysql/conf.d/my1.cnf

# Create database wikidb, mysql user wikiuser and give him access to the db
ADD create_mysql_wikidb_wikiuser.sh /create_mysql_wikidb_wikiuser.sh
RUN chmod 755 /create_mysql_wikidb_wikiuser.sh

ADD run1.sh /run1.sh
RUN chmod 755 /run1.sh

CMD ["/run1.sh"]
