FROM resin/raspberry-pi-alpine:3.6
RUN addgroup -g 3000 nixbld &&\
    for i in $(seq 1 4); do adduser -S -D -h /var/empty -g "Nix build user $i" -u $((30000 + i)) -G nixbld nixbld$i ; done &&\
    adduser -h /home/shell -s /bin/bash -S shell sudo &&\
    echo echo shell ALL=NOPASSWD:ALL > /etc/sudoers &&\
    chown -R shell /usr/local
RUN apk add --update sudo bash pkgconfig openssl-dev bzip2-dev autoconf flex g++ git make automake m4 patch sqlite-dev bison libsodium-dev libxml2-dev libxslt-dev curl curl-dev xz-dev xz libseccomp-dev &&\
    rm -r /var/cache/apk/*
ENV SQLITE3=sqlite
RUN su shell -c "git clone https://github.com/nixos/nix.git /home/shell/src &&\ 
	cd /home/shell/src &&\
	git checkout 1.11.15 &&\
	./bootstrap.sh &&\
	./configure &&\
	cd /home/shell/src && make -j4 doc_generate=no &&\
	make -j4 doc_generate=no install"
RUN su shell -c "sudo nix-store --init &&\
    	sudo ln -s /usr/local/etc/profile.d/nix.sh /etc/profile.d &&\
    	sudo chown -R shell /nix &&\
    	sudo ln -s /usr/bin/id /bin/id &&\
    	bash /usr/local/etc/profile.d/nix.sh &&\
	cd && rm -rf /src &&\
	nix-channel --add http://nixos-arm.dezgeg.me/channel nixpkgs"
ONBUILD RUN su shell -c "nix-channel --update"
ENTRYPOINT su - shell
CMD []
