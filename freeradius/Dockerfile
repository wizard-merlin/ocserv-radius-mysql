FROM ubuntu
RUN apt-get update \
    && apt-get install -y software-properties-common python-software-properties vim \
    && add-apt-repository -y ppa:freeradius/stable-3.0 \
    && apt-get update \
    && apt-get install -y freeradius freeradius-mysql mysql-client
COPY authorize /etc/freeradius/mods-config/files/authorize
COPY clients.conf /etc/freeradius/clients.conf
COPY sql /etc/freeradius/mods-available/sql
COPY sqlcounter /etc/freeradius/mods-available/sqlcounter
COPY default /etc/freeradius/sites-available/default
COPY dictionary /etc/freeradius/dictionary
COPY wait-for-mysql.sh /root/wait-for-mysql.sh
RUN ln -s /etc/freeradius/mods-available/sql /etc/freeradius/mods-enabled/sql \
    && ln -s /etc/freeradius/mods-available/sqlcounter /etc/freeradius/mods-enabled/sqlcounter
WORKDIR /etc/freeradius
CMD ["freeradius", "-X"]
EXPOSE 1812 1813 1814
#HEALTHCHECK CMD radtest testing password 127.0.0.1 0 testing123 | grep -q "Access-Accept"

