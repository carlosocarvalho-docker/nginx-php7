FROM carlosocarvalho/ubuntu-nginx-php7:1.0
MAINTAINER Carlos Carvalho <contato@carlosocarvalho.com.br>

# Default baseimage settings
ENV HOME /root
#RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
#CMD ["/sbin/my_init"]
ENV DEBIAN_FRONTEND noninteractive

# Update software list, install php-nginx & clear cache
RUN apt-get update && \
    
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/*
#purge php5
#            
RUN apt-get purge -f php5-common -y && \
    #apt-get install php7.0-mysql -y && \
    apt-get --purge autoremove -y

# Configure nginx
RUN echo "daemon off;" >>                                               /etc/nginx/nginx.conf
RUN sed -i "s/sendfile on/sendfile off/"                                /etc/nginx/nginx.conf
RUN mkdir -p                                                            /var/www

# Configure PHP
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"                  /etc/php/7.0/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = America\/Sao_Paulo/"        /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g"                 /etc/php/7.0/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"                  /etc/php/7.0/cli/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = America\/Sao_Paulo/"        /etc/php/7.0/cli/php.ini
#RUN php7enmod mcrypt

# Add nginx service
RUN mkdir -p                                                              /etc/service/nginx
ADD build/nginx/run.sh                                                  /etc/service/nginx/run
RUN chmod +x                                                            /etc/service/nginx/run

# Add PHP service
RUN mkdir -p                                                              /etc/service/phpfpm
ADD build/php/run.sh                                                    /etc/service/phpfpm/run
RUN chmod +x                                                            /etc/service/phpfpm/run

#run clear packages

RUN apt-get clean

#run composer update
RUN composer self-update          

# Add nginx
VOLUME ["/var/www", "/etc/nginx/sites-available", "/etc/nginx/sites-enabled"]

# Workdir
WORKDIR /var/www

EXPOSE 80