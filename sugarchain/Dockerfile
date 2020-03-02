# Build stage for BerkeleyDB
FROM alpine:3.11 as berkeleydb

ENV BERKELEYDB_VERSION=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VERSION}

RUN apk --no-cache add autoconf automake build-base libressl \
&& wget https://download.oracle.com/berkeley-db/${BERKELEYDB_VERSION}.tar.gz \
&& tar -xzf *.tar.gz \
&& sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ${BERKELEYDB_VERSION}/dbinc/atomic.h \
&& mkdir -p ${BERKELEYDB_PREFIX}

WORKDIR /${BERKELEYDB_VERSION}/build_unix

RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BERKELEYDB_PREFIX} \
&& make -j4 \
&& make install \
&& rm -rf ${BERKELEYDB_PREFIX}/docs

# Build stage for Sugarchain Yumekawa
FROM alpine:3.11 as sugarchain-yumekawa

COPY --from=berkeleydb /opt /opt

ENV SUGAR_VERSION=0.16.3.30-moonlight
ENV SUGAR_PREFIX=/opt/sugarchain

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
&& apk --no-cache add autoconf automake boost-dev build-base \
chrpath file gnupg libevent-dev libressl libressl-dev libtool \
linux-headers protobuf-dev zeromq-dev

RUN wget https://github.com/sugarchain-project/sugarchain/archive/v${SUGAR_VERSION}.tar.gz \
&& tar -xzf *.tar.gz

WORKDIR /sugarchain-${SUGAR_VERSION}

RUN ./autogen.sh \
&& ./configure LDFLAGS=-L`ls -d /opt/db*`/lib/ CPPFLAGS=-I`ls -d /opt/db*`/include/ \
    --prefix=${SUGAR_PREFIX} \
    --mandir=/usr/share/man \
    --disable-tests \
    --disable-bench \
    --disable-ccache \
    --with-gui=no \
    --with-utils \
    --with-libs \
    --with-daemon
RUN make -j4
RUN make install

RUN strip ${SUGAR_PREFIX}/bin/sugarchain-cli && \
strip ${SUGAR_PREFIX}/bin/sugarchaind && \
strip ${SUGAR_PREFIX}/bin/sugarchain-tx


# Build stage for compiled artifacts
FROM alpine:3.11

LABEL maintainer="Rakutens (@rakutens)"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
&& adduser -S sugarchain \
&& apk --no-cache add \
  boost \
  boost-program_options \
  libevent \
  libressl \
  libzmq \
  su-exec

ENV SUGAR_DATA=/home/sugarchain/.sugarchain
ENV SUGAR_PREFIX=/opt/sugarchain
ENV PATH=${SUGAR_PREFIX}/bin:$PATH


COPY --from=sugarchain-yumekawa /opt /opt
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/home/sugarchain/.sugarchain"]

EXPOSE 34229 34230 44229 44230 45339 45340

ENTRYPOINT ["/entrypoint.sh"]

CMD ["sugarchaind"]