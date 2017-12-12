FROM resin/rpi-raspbian:stretch
RUN apt-get update &&\
    apt-get install -y sudo pkg-config openssl bzip2 autoconf flex g++ git\
		       make automake m4 patch sqlite3 bison docbook \
		       libsodium-dev libxml2-dev libxslt-dev libssl-dev libbz2-dev \
                       libsqlite3-dev libcurl3-openssl-dev liblzma-dev libseccomp-dev &&\
    rm -rf /var/lib/apt/lists/*
ENV SQLITE3=sqlite3
RUN addgroup --gid 3000 nixbld &&\
    for i in $(seq 1 2); do adduser --quiet --uid $((30000 + i)) --ingroup nixbld --no-create-home --disabled-login nixbld${i} && usermod -a -G nixbld nixbld${i}; done &&\
    adduser --quiet --shell /bin/bash --ingroup sudo --home /home/shell shell &&\
    echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers &&\
    ln -s /usr/local/etc/profile.d/nix.sh /etc/profile.d 
RUN su -c "git clone https://github.com/nixos/nix.git /home/shell/src &&\ 
	cd /home/shell/src &&\
	./bootstrap.sh &&\
	./configure" -m shell
WORKDIR /home/shell/src
RUN chown -R shell /usr/local
RUN su -c "make -j3 doc_generate=no" -m shell
RUN su -c "make doc_generate=no install" -m shell
RUN nix-store --init &&\
    chown -R shell /nix &&\
    ln -s /usr/bin/stat /bin/stat &&\
    ln -s /usr/bin/id /bin/id &&\
    bash /usr/local/etc/profile.d/nix.sh &&\
    su -c "nix-channel --add https://nixos.org/channels/nixpkgs-unstable" -m shell &&\
    su -c "nix-channel --update" -m shell
ENTRYPOINT su - shell
CMD []
