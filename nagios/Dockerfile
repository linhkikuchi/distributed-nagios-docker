FROM centos:latest

# Install packages, EPEL must come first
RUN yum -y update && yum -y install epel-release
RUN yum -y install wget gd gd-devel wget httpd php gcc make perl tar unzip libcurl-devel \
  nagios nagios-plugins-ifoperstatus nagios-plugins-ifstatus \
  nagios-plugins-all nagios-plugins-nrpe nagios-plugins-apt \
  supervisor mod_ldap

## install perl modules for nagios plugins

RUN yum -y install perl-Data-Dumper perl-WWW-Curl perl-JSON python-pip perl-devel

# Install mod-gearman
RUN yum -y install gearmand logrotate

RUN cd /tmp && wget ftp://rpmfind.net/linux/Mandriva/devel/cooker/x86_64/media/contrib/release/lib64gearman6-0.32-1-mdv2012.0.x86_64.rpm && rpm -Uvh lib64gearman6-0.32-1-mdv2012.0.x86_64.rpm

RUN cd /tmp && wget https://mod-gearman.org/download/v3.0.2/rhel7/x86_64/mod_gearman-3.0.2-1.rhel7.x86_64.rpm && rpm -Uvh mod_gearman-3.0.2-1.rhel7.x86_64.rpm

# COPY the existing plugins to new server (if any)
# ADD plugins/* /usr/lib64/nagios/plugins/

# add nagios.cfg to /etc/nagios
ADD nagios.cfg /etc/nagios/

# add gearman config to /etc/mod_gearman
ADD module.conf /etc/mod_gearman/

# add telegram_nagios (if needed)
RUN pip install argparse pyTelegramBotAPI

# for check_snmp_synology
RUN yum -y install net-snmp net-snmp-utils which

# install vSphere SDK for Perl package for check_vmware_api
# https://github.com/op5/check_vmware_api
RUN yum -y install openssl-devel perl-Archive-Zip perl-Class-MethodMaker uuid-perl perl-SOAP-Lite perl-XML-SAX perl-XML-NamespaceSupport perl-XML-LibXML perl-MIME-Lite perl-MIME-Types perl-MailTools perl-TimeDate uuid libuuid perl-Data-Dump perl-UUID cpan libxml2-devel perl-libwww-perl perl-Test-MockObject perl-Test-Simple perl-Monitoring-Plugin perl-Class-Accessor perl-Config-Tiny e2fsprogs
ADD VMware-vSphere-Perl-SDK-6.5.0-4566394.x86_64.tar.gz /tmp/
RUN sed -i '2621,2635d' /tmp/vmware-vsphere-cli-distrib/vmware-install.pl && /tmp/vmware-vsphere-cli-distrib/vmware-install.pl -d EULA_AGREED=yes && rm -rf /tmp/vmware-vsphere-cli-distrib/

RUN pip install pymongo
RUN pip install suds

# Install mod-gearman
RUN yum -y install gearmand logrotate
RUN cd /tmp && wget ftp://rpmfind.net/linux/Mandriva/devel/cooker/x86_64/media/contrib/release/lib64gearman6-0.32-1-mdv2012.0.x86_64.rpm && rpm -Uvh lib64gearman6-0.32-1-mdv2012.0.x86_64.rpm && rm -rf /tmp/lib64gearman6-0.32-1-mdv2012.0.x86_64.rpm
RUN cd /tmp && wget https://mod-gearman.org/download/v3.0.2/rhel7/x86_64/mod_gearman-3.0.2-1.rhel7.x86_64.rpm && rpm -Uvh mod_gearman-3.0.2-1.rhel7.x86_64.rpm && rm -rf /tmp/mod_gearman-3.0.2-1.rhel7.x86_64.rpm

RUN cd /tmp && wget https://labs.consol.de/assets/downloads/nagios/check_mysql_health-2.2.2.tar.gz
RUN cd /tmp && tar xvzf check_mysql_health-2.2.2.tar.gz
RUN cd /tmp/check_mysql_health-2.2.2 && ./configure --with-nagios-user=root --with-nagios-group=root && make && make install && rm -rf /tmp/check_mysql_health-2.2.2 && rm -rf /tmp/check_mysql_health-2.2.2.tar.gz
RUN cp /usr/local/nagios/libexec/check_mysql_health /usr/lib64/nagios/plugins/

RUN cd /tmp && wget http://www.cpan.org/authors/id/J/JE/JESUS/Net--RabbitMQ-0.2.8.tgz
RUN cd /tmp && tar xvzf Net--RabbitMQ-0.2.8.tgz
RUN cd /tmp/Net--RabbitMQ-0.2.8 && perl Makefile.PL && make && make install
RUN rm -rf /tmp/Net--RabbitMQ-0.2.8 && rm -rf /tmp/Net--RabbitMQ-0.2.8.tgz

# install postfix to sendmail alert for Nagios
RUN yum install -y postfix supervisor rsyslog
RUN sed -i "s/inet_interfaces = localhost/inet_interfaces = all/g" /etc/postfix/main.cf
RUN echo mynetworks = 172.0.0.0/8, 10.0.0.0/8, 127.0.0.0/8, 192.168.0.0/16 >> /etc/postfix/main.cf
RUN echo relayhost = monitor1.sli-systems.com >> /etc/postfix/main.cf
RUN echo myhostname = nagios-chc.sli.io >> /etc/postfix/main.cf
RUN sed -i "s/mailhub=mail/mailhub=smtp.globalbrain.net:25/g" /etc/ssmtp/ssmtp.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY rsyslog.conf /etc/rsyslog.conf
COPY listen.conf /etc/rsyslog.d/listen.conf

# install dependency for NAGIOS API
RUN yum -y install python-devel
RUN pip install diesel

# add all script to local/bin
# ADD run/* /usr/local/bin/
# RUN chmod +x /usr/local/bin/*

# supervisor configuration
ADD supervisord.conf /etc/supervisord.conf

# add ldap config for nagios
ADD nagios.ldap.conf /etc/httpd/conf.d/nagios.conf

# Define data volumes
VOLUME /var/log/nagios
VOLUME /etc/nagios
VOLUME /var/spool/nagios
VOLUME /etc/mod_gearman
VOLUME /var/log/mod_gearman

EXPOSE 80 4730 25 6315
#4730 is for gearmand
#6315 is for nagios API, it can be any port no

CMD ["/usr/bin/supervisord"]


