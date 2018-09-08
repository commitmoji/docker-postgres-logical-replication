#!/bin/bash

echo "***** running /root/bin/init.sh"
echo "***** current interfaces:"
ifconfig
echo "***** setting default deny all policy on firewall"
ufw default reject incoming
echo "***** enabling firewall"
ufw enable
echo "***** firewall status:"
ufw status
echo "***** starting cron"
service cron start
echo "***** getting postgres' home all set"
usermod -s /bin/bash -d /home/postgres -aG efs postgres
mkdir -m 700 /home/postgres/bin 2>&1 > /dev/null
echo 'export PATH=$HOME/bin:/usr/lib/postgresql/10/bin:$PATH' >> /home/postgres/.profile 
echo "export PGDATA=${PGDATA}" >> /home/postgres/.profile
echo 'export $(cat ~/.env)' >> /home/postgres/.profile
chown -R postgres:postgres /home/postgres

echo "***** kicking off /home/postgres/bin/init.sh"
su -c '/home/postgres/bin/init.sh 2>&1' - postgres
echo "***** /home/postgres/bin/init.sh came back"
echo "***** allowing traffic on 5432"
ufw allow 5432

t_int()
{
    su -c 'pg_ctl stop' - postgres
}

trap 't_int' INT

echo "***** initialization done, sleeping"
sleep infinity