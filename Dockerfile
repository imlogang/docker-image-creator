FROM cimg/base:2023.07

ENV PG_VER=%%VERSION_FULL%%
ENV PG_MAJOR=%%VERSION_MAJOR%%
ENV POSTGRES_HOST_AUTH_METHOD=trust
ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
ENV POSTGRES_DB=circle_test
ENV PGTAP_VERSION 1.2.0
ENV PARTMAN_VERSION 4.7.2

USER root
RUN BUILD_DEPS="clang \
		dirmngr \
		gnupg \
		libclang-dev \
		libicu-dev \
		libipc-run-perl \
		libkrb5-dev \
		libldap2-dev \
		liblz4-dev \
		libpam-dev \
		libperl-dev \
		libpython3-dev \
		libreadline-dev \
		libssl-dev \
		libxml2-dev \
		libxslt1-dev \
		llvm \
		llvm-dev \
		postgresql-server-dev-all \
		python3-dev \
		tcl-dev \
		uuid-dev" && \
	apt-get update && apt-get install -y --no-install-recommends \
	gosu \
	locales \
	$BUILD_DEPS \
	&& \
	rm -rf /var/lib/apt/lists/* && \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
	curl -sSL "https://ftp.postgresql.org/pub/source/v${PG_VER}/postgresql-${PG_VER}.tar.gz" | tar -xz && \
	cd postgresql-${PG_VER} && \
	./configure \
		--prefix=/usr/lib/postgresql/$PG_MAJOR \
		--enable-integer-datetimes \
		--enable-thread-safety \
		--enable-tap-tests \
		--with-uuid=e2fs \
		--with-gnu-ld \
		--with-pgport=5432 \
		--with-system-tzdata=/usr/share/zoneinfo \
		--with-includes=/usr/local/include \
		--with-libraries=/usr/local/lib \
		--with-krb5 \
		--with-gssapi \
		--with-ldap \
		--with-pam \
		--with-tcl \
		--with-perl \
		--with-python \
		--with-openssl \
		--with-libxml \
		--with-libxslt \
		--with-icu \
		--with-llvm \
		--with-lz4 \
	&& \
	# we can change from world to world-bin in newer releases
	make -j $(nproc) world && \
	make install-world && \
	cd .. && rm -rf postgresql-${PG_VER} \
	&& \
	git clone --depth 1 https://github.com/citusdata/pg_cron.git /pg_cron && \
	cd /pg_cron && make && PATH=$PATH make install && \
	rm -rf /pg_cron && \
	apt-get purge -y --auto-remove $BUILD_DEPS

RUN curl -sSL "https://github.com/pgpartman/pg_partman/archive/v${PARTMAN_VERSION}.tar.gz" | tar -xz && \
	cd pg_partman-${PARTMAN_VERSION} && make NO_BGW=1 install && \
	cd .. && rm -rf pg_partman-${PARTMAN_VERSION}

# Install pgTAP & pg_prove utility.
RUN git clone --depth 1 -b "v$PGTAP_VERSION" https://github.com/theory/pgtap.git /pgtap && \
	cd /pgtap && make -j $(nproc) && make install && \
	curl -sL https://cpanmin.us | perl - App::cpanminus && \
	cpanm -n TAP::Parser::SourceHandler::pgTAP && \
	rm -rf /pgtap

RUN mkdir /docker-entrypoint-initdb.d

#COPY pg_cron.sh /docker-entrypoint-initdb.d/
COPY custom-postgresql.conf /etc/postgresql/custom-postgresql.conf
COPY docker-entrypoint.sh /usr/local/bin/

# Backwards compatibility
RUN ln -s usr/local/bin/docker-entrypoint.sh /

# removed /docker-entrypoint-initdb.d/pg_cron.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
	mkdir -p /var/lib/postgresql && \
	chown -R postgres:postgres /var/lib/postgresql && \
	chown -R postgres:postgres /etc/postgresql && \
	chown -R postgres:postgres /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
STOPSIGNAL SIGINT
EXPOSE 5432
CMD ["postgres"]
