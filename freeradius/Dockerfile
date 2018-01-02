FROM ubuntu
RUN apt-get update \
    && apt-get install -y software-properties-common python-software-properties vim \
    && add-apt-repository -y ppa:freeradius/stable-3.0 \
    && apt-get update \
    && apt-get install -y freeradius freeradius-rest freeradius-mysql mysql-client libcrypt-pbkdf2-perl
COPY authorize /etc/freeradius/mods-config/files/authorize
COPY clients.conf /etc/freeradius/clients.conf
COPY sql /etc/freeradius/mods-available/sql
COPY sqlcounter /etc/freeradius/mods-available/sqlcounter
COPY default /etc/freeradius/sites-available/default
COPY dictionary /etc/freeradius/dictionary
COPY accounting /etc/freeradius/policy.d/accounting
COPY queries.conf /etc/freeradius/mods-config/sql/main/mysql/queries.conf
COPY perl /etc/freeradius/mods-available/perl
COPY auth.pl /etc/freeradius/mods-config/perl/auth.pl
COPY rest /etc/freeradius/mods-available/rest
COPY wait-for-mysql.sh /root/wait-for-mysql.sh
RUN ln -s /etc/freeradius/mods-available/sql /etc/freeradius/mods-enabled/sql \
    && ln -s /etc/freeradius/mods-available/sqlcounter /etc/freeradius/mods-enabled/sqlcounter \
    && ln -s /etc/freeradius/mods-available/perl /etc/freeradius/mods-enabled/perl \
    && ln -s /etc/freeradius/mods-available/rest /etc/freeradius/mods-enabled/rest

WORKDIR /etc/freeradius
CMD ["freeradius", "-X"]
EXPOSE 1812 1813 1814
#HEALTHCHECK CMD radtest testing password 127.0.0.1 0 testing123 | grep -q "Access-Accept"

