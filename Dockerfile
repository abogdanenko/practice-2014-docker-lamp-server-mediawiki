FROM tutum/lamp:latest
MAINTAINER Alexey Bogdanenko <abogdanenko@dentavita.ru>

# Install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-gd php5-intl

# Add Apache virtual host file for website wiki.dv.ru
ADD wiki.dv.ru.conf /etc/apache2/sites-available/wiki.dv.ru.conf
RUN a2ensite wiki.dv.ru.conf

ADD my1.cnf /etc/mysql/conf.d/my1.cnf
