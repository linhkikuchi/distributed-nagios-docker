FROM centos:latest

# Install packages, EPEL must come first
RUN yum -y update && yum -y install epel-release
RUN yum -y install wget gd gd-devel wget httpd php gcc make perl tar unzip libcurl-devel \
  nagios-plugins-ifoperstatus nagios-plugins-ifstatus \
  nagios-plugins-all nagios-plugins-nrpe nagios-plugins-apt \
  supervisor mod_ldap

## install perl modules for nagios plugins
RUN yum -y install perl-Data-Dumper perl-WWW-Curl perl-JSON python-pip perl-devel

# Install mod-gearman
RUN yum -y install gearmand logrotate

RUN cd /tmp && wget ftp://rpmfind.net/linux/Mandriva/devel/cooker/x86_64/media/contrib/release/lib64gearman6-0.32-1-mdv2012.0.x86_64.rpm && rpm -Uvh lib64gearman6-0.32-1-mdv2012.0.x86_64.rpm

RUN cd /tmp && wget https://mod-gearman.org/download/v3.0.2/rhel7/x86_64/mod_gearman-3.0.2-1.rhel7.x86_64.rpm && rpm -Uvh mod_gearman-3.0.2-1.rhel7.x86_64.rpm

# install additional plugins
RUN cd /tmp && wget https://labs.consol.de/assets/downloads/nagios/check_mysql_health-2.2.2.tar.gz
RUN cd /tmp && tar xvzf check_mysql_health-2.2.2.tar.gz
RUN cd /tmp/check_mysql_health-2.2.2 && ./configure --with-nagios-user=root --with-nagios-group=root && make && make install

RUN cd /tmp && wget http://www.cpan.org/authors/id/J/JE/JESUS/Net--RabbitMQ-0.2.8.tgz
RUN cd /tmp && tar xvzf Net--RabbitMQ-0.2.8.tgz
RUN cd /tmp/Net--RabbitMQ-0.2.8 && perl Makefile.PL && make && make install

# COPY the existing plugins to new server (if any)
# worker needs to have all plugins as the master Nagios server
ADD plugins/* /usr/lib64/nagios/plugins/

# add all script to local/bin (if any)
# ADD run/* /usr/local/bin/
# RUN chmod +x /usr/local/bin/*

# add gearman worker config to /etc/mod_gearman
ADD worker.conf /etc/mod_gearman/

# supervisor configuration
ADD supervisord.conf /etc/supervisord.conf


# Define data volumes
VOLUME /etc/mod_gearman
VOLUME /var/log/mod_gearman

CMD ["/usr/bin/supervisord"]


