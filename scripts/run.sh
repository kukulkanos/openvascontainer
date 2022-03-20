#!/bin/bash
#echo "net.core.somaxconn = 1024"  >> /etc/sysctl.conf
#echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
export LD_LIBRARY_PATH='/usr/local/lib'
echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled && echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
mkdir -p /run/redis
chmod 777 /run/redis /var/lib/redis
chown -Rv greenbone:root /etc/redis/
su greenbone -c "redis-server /etc/redis/redis.conf" &
su postgres -c "/usr/lib/postgresql/13/bin/postgres --config-file=/etc/postgresql/13/main/postgresql.conf" &
sleep 10
su postgres -c "createuser -DRS greenbone"
#su postgres -c "createuser -DRS root"
su postgres -c "createdb -O greenbone gvmd"
#su postgres -c "createdb -O root gvmd"
su postgres -c "psql -d gvmd -c \"create role dba with superuser noinherit;\""
#su postgres -c "psql -d gvmd -c \"grant dba to root;\""
su postgres -c "psql -d gvmd -c \"grant dba to greenbone;\""
su postgres -c "psql -d gvmd -c \"create extension \\\"uuid-ossp\\\";\""
su postgres -c "psql -d gvmd -c \"create extension \\\"pgcrypto\\\";\""
mkdir -p /var/log/gvm
mkdir -p /usr/local/var/log/gvm/
chmod 777 /var/log/gvm
chmod 777 /usr/local/var/log/gvm/
mkdir -p /run/gvm
chmod 777 /run/gvm
mkdir -p /run/ospd
chmod 777 /run/ospd
mkdir -p /usr/local/var/lib/gvm/data-objects/
chmod 777 /usr/local/var/lib/gvm/data-objects/
rm /run/gvm/ospd-openvas.pid
rm /run/gvm/feed-update.lock
#su greenbone -c ""
/usr/local/bin/ospd-openvas --config=/etc/ospd/ospd.conf --pid-file /run/gvm/ospd-openvas.pid --log-file /var/log/gvm/ospd-openvas.log --lock-file-dir /var/run/gvm -u /var/run/ospd/ospd.sock
su greenbone -c "gvmd --create-user greenbone --password=Op3nV4sD3fault"
FEED_OWNER=`su greenbone -c "gvmd --get-users --verbose" | grep greenbone | awk '{print $2}'`
su greenbone -c "gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value $FEED_OWNER"
su greenbone -c "gsad --listen 0.0.0.0 --port 9443 --mlisten 127.0.0.1 --mport 9390 --timeout 60 --rport=80"
echo "greenbone ALL = NOPASSWD: /usr/local/sbin/openvas" > /etc/sudoers.d/greenbone
echo "greenbone ALL = NOPASSWD: /usr/local/sbin/gsad" > /etc/sudoers.d/greenbone
#su greenbone -c "greenbone-feed-sync --type GVMD_DATA"; sleep 120 ; su greenbone -c greenbone-scapdata-sync; sleep 30; su greenbone -c greenbone-certdata-sync; sleep 30; su greenbone -c greenbone-nvt-sync ; 
su greenbone -c "gvmd --listen 127.0.0.1 --port 9390 --max-ips-per-target=65536"
sleep 300
su greenbone -c "gvmd --create-user greenbone --password=Op3nV4sD3fault"
/bin/bash