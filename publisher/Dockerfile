FROM ubuntu:16.04

ENV PGDATA /var/lib/postgresql/10/main
ENV PGHOME /usr/lib/postgresql/10

# get os up-to-date
RUN apt-get update -y \
	&& apt-get upgrade -y

# get basic tools
RUN apt-get install -y wget sudo software-properties-common nano net-tools ufw iputils-ping netcat

# prep for postgres installation
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list' \
	&& add-apt-repository 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' \ 
	&& wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
	&& apt-get update

# postgres installation
RUN sudo apt-get install -y postgresql postgresql-contrib

# make efs group
RUN groupadd -g 501 efs

EXPOSE 5432

## prep for efs mount
RUN mkdir -p /mnt/efs/db \
    && chown -R root:efs /mnt/efs/db \
    && chmod -R 770 /mnt/efs/db
VOLUME ['/mnt/efs/db']

# copy homes
COPY mnt/home/root /root
COPY mnt/home/postgres /home/postgres

CMD /root/bin/init.sh