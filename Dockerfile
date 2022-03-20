FROM kalilinux/kali-rolling
RUN apt update
RUN apt upgrade -y
RUN apt install -y bison cmake gcc g++ gcc-mingw-w64 heimdal-dev libgcrypt20-dev libglib2.0-dev libgnutls28-dev libgpgme-dev libhiredis-dev libksba-dev libmicrohttpd-dev git libpcap-dev libpopt-dev libsnmp-dev libsqlite3-dev libssh-gcrypt-dev xmltoman libxml2-dev perl-base pkg-config python3-paramiko python3-setuptools uuid-dev curl redis doxygen libical-dev gnutls-bin wget git curl rsync
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update
RUN apt install -y yarn
RUN mkdir -p /tmp/gvm10
#ENMIENDAS DE DEPENDENCIAS
RUN apt install -y libsmbclient-dev libldap-dev
RUN apt install -y freeradius-utils libfreeradius3 libradcli4
RUN apt install -y python3-dev python-dev
RUN apt install -y postgresql libpq-dev postgresql-server-dev-all
RUN apt install -y alien bind9-host brutespray cewl curl dirb dnsenum dnsrecon dos2unix exif exploitdb eyewitness git hsqldb-utils hydra ike-scan iproute2 john joomscan jq kafkacat ldap-utils libgmp-dev libnet-whois-ip-perl libxml2-utils libwww-mechanize-perl libpostgresql-jdbc-java libjt400-java libjtds-java libderby-java libghc-hdbc-dev libhsqldb-java mariadb-common metasploit-framework ncat ncrack nikto nmap nmap-common nsis open-iscsi postgresql-client-common python3-pip routersploit rpcbind rpm rsh-client ruby screen seclists skipfish sqlline snmpcheck time tnscmd10g unzip wapiti wfuzz wget whatweb wig wordlists wpscan xmlstarlet zaproxy
COPY source/* /tmp/gvm10/
RUN cd /tmp/gvm10 && for i in *.tar.gz; do echo $i ; tar xzf $i; done && \
cd /tmp/gvm10/gvm-libs-20.8.0 && mkdir -p build && cd build && cmake .. && make -j8 && make install && \
cd /tmp/gvm10/openvas-smb-1.0.5 && mkdir -p build && cd build && cmake .. && make -j8 && make install && \
cd /tmp/gvm10/ospd-20.8.1 && python3 setup.py install && \
cd /tmp/gvm10/ospd-openvas-20.8.0 && python3 setup.py install && \
cd /tmp/gvm10/openvas-20.8.0 && mkdir -p build && cd build && cmake .. && make -j8 && make install
RUN cd /tmp/gvm10/gvmd-20.8.0 && mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=RELEASE -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql .. && make -j8 && make install
RUN cd /tmp/gvm10/gsa-20.8.0 && mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=RELEASE .. && make -j8 && make install
#REDIS SERVER
RUN echo "net.core.somaxconn = 1024"  >> /etc/sysctl.conf
RUN echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
RUN mv -v /etc/redis/redis.conf /etc/redis/redis.conf.bak
RUN mkdir -p /usr/local/etc/openvas/ && chmod 777 /usr/local/etc/openvas/ && mkdir -p /usr/local/var/run && chmod 777 /usr/local/var/run && mkdir -p /usr/local/var/lib/openvas/ 
RUN echo "db_address = /var/run/redis/redis.sock" > /usr/local/etc/openvas/openvassd.conf
COPY config/etc/redis/redis.conf /etc/redis/redis.conf
#COPY config/redis_4_0.conf /etc/redis/redis_4_0.conf
RUN useradd greenbone && usermod -a -G root greenbone
RUN apt install -y xml-twig-tools  t1utils vim-common vim-runtime wget x11-common xdg-utils xkb-data xmlstarlet xsltproc xz-utils zlib1g xxd unzip ucf tex-common texlive-base texlive-binaries texlive-fonts-recommended texlive-latex-base texlive-latex-extra texlive-latex-recommended texlive-pictures thin-provisioning-tools sysstat ssl-cert socat sensible-utils sqlite3 snmp rrdtool procps poppler-data pnscan pinentry-curses perl perl-openssl-defaults pciutils perl-base perl-modules-* nsis-common nsis netbase netfilter-persistent mysql-common mime-support mawk mariadb-common lua-cjson lua-bitop lsb-release lsb-base logrotate ldap-utils kmod klibc-utils iptables ieee-data haveged graphviz gnupg-utils fonts-lmodern fonts-dejavu-core fontconfig fontconfig-config diffutils dirmngr corkscrew ca-certificates bsdutils bsdmainutils ansible mc sudo iputils-ping
ADD --chown=greenbone:root feeds/usr-local-var-lib-openvas.tgz /
RUN chmod 777 /dev/stderr && chmod 777 -Rv /usr/local/var/lib/
RUN mkdir -p /usr/local/var/lib/gvm/cert-data/ ; chmod 777 /usr/local/var/lib/gvm/cert-data/ ; \
mkdir -p /usr/local/var/lib/gvm/scap-data/ ; chmod 777 /usr/local/var/lib/gvm/scap-data/; \
mkdir -p /usr/local/var/lib/gvm/data-objects/ ; chmod 777 /usr/local/var/lib/gvm/data-objects/
RUN su greenbone -c "greenbone-feed-sync --type GVMD_DATA"; sleep 120 ; su greenbone -c greenbone-scapdata-sync; sleep 30; su greenbone -c greenbone-certdata-sync; sleep 30; su greenbone -c greenbone-nvt-sync ; 
#RUN gvm-manage-certs -a
#RUN ldconfig && gvmd --create-user openvasadmin --password=Op3nV4sD3fault
COPY config/gvm.conf /etc/ld.so.conf.d/
COPY config/etc/ospd/ospd.conf /etc/ospd/ospd.conf
COPY scripts/*.sh /
RUN chmod +x /*.sh; ldconfig
EXPOSE 9443
ENTRYPOINT ["/run.sh"]
