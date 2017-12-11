FROM resin/rpi-raspbian:stretch
RUN apt-get update &&\
    apt-get install -y pkg-config openssl bzip2 autoconf flex g++ git\
		       make automake m4 patch sqlite3 bison docbook \
		       libxml2-dev libxslt-dev libssl-dev libbz2-dev \
                       libsqlite3-dev libcurl3-openssl-dev liblzma-dev libseccomp-dev &&\
    rm -rf /var/lib/apt/lists/*
ENV SQLITE3=sqlite3
RUN addgroup --gid 3000 nixbld &&\
    for i in $(seq 1 2); do adduser --quiet --uid $((30000 + i)) --ingroup nixbld --no-create-home --disabled-login nixbld${i}; done &&\
    adduser --quiet --shell /usr/bin/bash --ingroup sudo --home /home/shell shell &&\
    ln -s /usr/local/etc/profile.d/nix.sh /etc/profile.d
RUN git clone https://github.com/nixos/nix.git /src && cd /src && git checkout 1.11.9 && ./bootstrap.sh && ./configure && make -j3 doc_generate=no && make doc_generate=no install
RUN git clone https://github.com/nixos/nixpkgs.git
