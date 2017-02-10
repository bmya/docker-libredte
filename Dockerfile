FROM ubuntu:14.04
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install apache2 php5 git wget mercurial curl vim php5-curl
WORKDIR /
RUN wget -c https://github.com/SowerPHP/sowerpkg/raw/master/sowerpkg.sh
RUN chmod +x sowerpkg.sh
RUN a2enmod rewrite
RUN apache2ctl restart

RUN sed  -i  "s/\/var\/www/\/var\/www\/html/" /sowerpkg.sh

RUN ./sowerpkg.sh install -e "LibreDTE Company" -W

WORKDIR /var/www/html
RUN git clone --recursive https://github.com/LibreDTE/libredte-webapp.git libredte
RUN chown -R www-data:www-data libredte
RUN chmod -R 775 .

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === 'aa96f26c2b67226a324c27919f1eb05f21c248b987e6195cad9690d5c1ff713d53020a02ac8c217dbf90a7eacc9d141d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"

RUN useradd -ms /bin/bash libredte
RUN usermod -aG www-data libredte
USER libredte

RUN mv composer.phar /usr/local/bin/composer
WORKDIR /var/www/html/libredte/website
RUN composer install
WORKDIR /var/www/html/libredte/website/Config

# COPY ./core-dist.php core.php
RUN cp core-dist.php core.php


