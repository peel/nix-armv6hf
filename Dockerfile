FROM resin/rpi-raspbian:stretch
RUN apt-get update &&\
    apt-get install -y pkg-config openssl bzip2 autoconf flex g++ git\
		       make automake m4 patch sqlite3 docbook \
		       libxml2-dev libxslt-dev libssl-dev libbz2-dev \
                       libsqlite3-dev libcurl3-openssl-dev liblzma-dev libseccomp-dev
ENV SQLITE3=sqlite3
RUN git clone https://github.com/nixos/nix.git /src
WORKDIR /src
RUN ./bootstrap.sh && ./configure.sh && make doc_generate=no && make doc_generate=no install
