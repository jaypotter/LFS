FROM	fedora:41

WORKDIR	/root/

RUN	dnf update -y

#
# Host System Requirements
#

RUN	dnf install bash binutils bison \
		coreutils diffutils findutils \
		gawk gcc grep \
		gzip kernel m4 \
		make patch perl \
		python sed tar \
		texinfo xz -y

# /bin/sh should be a symbolic or hard link to bash
RUN	ln -sfv bash	/bin/sh

# /usr/bin/yacc should be a link to bison or a small script that executes bison
RUN	ln -sfv bison	/usr/bin/yacc

# /usr/bin/awk should be a link to gawk
RUN	ln -sfv gawk	/usr/bin/awk

RUN	dnf install wget -y && \
	wget -v https://raw.githubusercontent.com/jaypotter/LFS/refs/heads/main/version-check.sh && \
	chmod +x version-check.sh && \
	./version-check.sh
