#!/bin/bash

echo "***** kicking off /home/postgres/bin/init.sh"

echo "***** setting default deny all policy on firewall"
ufw default reject incoming
echo "***** enabling firewall"
ufw enable
echo "***** firewall status:"
ufw status

echo "***** getting postgres' home all set"
cp -r /etc/skel /home/postgres
usermod -s /bin/bash -d /home/postgres -aG efs postgres
mkdir -m 700 /home/postgres/bin
echo 'export PATH=$HOME/bin:/usr/lib/postgresql/10/bin:$PATH' >> /home/postgres/.profile
echo "export PGDATA=${PGDATA}" >> /home/postgres/.profile
echo 'export $(cat ~/.env)' >> /home/postgres/.profile
chown -R postgres:postgres /home/postgres

su -c /home/postgres/bin/init.sh - postgres
#su - postgres -c "tail -f /home/postgres/logfile"

echo "***** allowing traffic on 5432"
ufw allow 5432

sleep infinity