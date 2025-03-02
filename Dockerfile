FROM	fedora:41

WORKDIR	/root/

RUN	dnf update -y

# Host System Requirements

RUN	dnf install bash binutils bison \
		coreutils diffutils findutils \
		gawk gcc grep \
		gzip kernel m4 \
		make patch perl \
		python sed tar \
		texinfo xz -y

RUN	ln -sf bash	/bin/sh		# /bin/sh should be a symbolic or hard link to bash
RUN	ln -sf bison	/usr/bin/yacc	# /usr/bin/yacc should be a link to bison or a small script that executes bison
RUN	ln -sf gawk	/usr/bin/awk	# /usr/bin/awk should be a link to gawk
