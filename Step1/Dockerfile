FROM	fedora:41

RUN	mkdir /lfs
WORKDIR	/lfs

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

# Version Check
RUN	dnf install wget -y && \
	wget -v https://raw.githubusercontent.com/jaypotter/LFS/refs/heads/main/version-check.sh && \
	chmod +x version-check.sh && \
	./version-check.sh

#
# Creating a New Partition
#

RUN	dd if=/dev/zero of=lfs bs=1M count=4096 status=progress

#
# Creating a File System on the Partition 
#

RUN	dnf install e2fsprogs -y && \
	mkfs.ext4 -v lfs && \
	mkdir -v mnt

#
# Setting The $LFS Variable
#

ENV	LFS=/lfs/mnt

#
# Packages and Patches
#

RUN	mkdir sources && \
	wget -v https://raw.githubusercontent.com/jaypotter/LFS/refs/heads/main/wget-list-sysv && \
	wget -v --input-file=wget-list-sysv --continue --directory-prefix=sources && \
	wget -v https://www.linuxfromscratch.org/lfs/view/stable/md5sums && \
	mv -v md5sums sources && \
	pushd sources && \
		md5sum -c md5sums && \
	popd

#
# Creating a Limited Directory Layout in the LFS Filesystem 
#
RUN	mkdir -pv skeleton/{etc,var} skeleton/usr/{bin,lib,sbin} && \
	case $(uname -m) in \
		x86_64) mkdir -v skeleton/lib64 ;; \
	esac && \
	mkdir -v skeleton/tools

#
# Adding the LFS User
#

RUN	groupadd lfs && \
	useradd -s /bin/bash -g lfs -m -k /dev/null lfs && \
	echo alpine | passwd lfs --stdin

#
# Setting Up the Environment
#

RUN	echo "exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash" >> /home/lfs/.bash_profile && \
	echo -e "set +h \n \
		umask 022 \n \
		LFS=/lfs/mnt \n \
		LC_ALL=POSIX \n \
		LFS_TGT=$(uname -m)-potter-linux-gnu \n \
		PATH=/usr/bin \n \
		if [ ! -L /bin ]; then PATH=/bin:$PATH; fi \n \
		PATH=$LFS/tools/bin:$PATH \n \
		CONFIG_SITE=$LFS/usr/share/config.site \n \
		export LFS LC_ALL LFS_TGT PATH CONFIG_SITE \n \
		export MAKEFLAGS=-j`nproc --ignore=2`" >> /home/lfs/.bashrc && \
	chown lfs:lfs -R /home/lfs/

#
# Start Script
#

RUN	echo -e "#!/bin/bash \n \
		mount -v lfs $LFS \n \
		mv -v sources $LFS/sources \n \
		mv -v skeleton/* $LFS \n \
		for i in bin lib sbin; do \n \
			ln -sv $LFS/usr/$i $LFS/\$i \n \
		done \n \
		chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools} \n \
		case $(uname -m) in \n \
			x86_64) chown -v lfs $LFS/lib64 ;; \n \
		esac" >> start.sh && \
	chmod +x start.sh
