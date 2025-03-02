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

RUN	dd if=/dev/zero of=lfs bs=1M count=20480 status=progress

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
# Start Script
#

RUN	echo -e "#!/bin/bash \n \
		mount -v lfs $LFS \n \
		wget -v https://raw.githubusercontent.com/jaypotter/LFS/refs/heads/main/wget-list-sysv \n \
		wget -v --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources \n \
		wget -v https://www.linuxfromscratch.org/lfs/view/stable/md5sums \n \
		mv -v md5sums $LFS/sources \n \
		pushd $LFS/sources \n \
			md5sum -c md5sums \n \
		popd \n \
		mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin} \n \
		for i in bin lib sbin; do \n \
			ln -sv $LFS/usr/$i $LFS/$i \n \
		done \n \
		case $(uname -m) in \n \
			x86_64) mkdir -v $LFS/lib64 ;; \n \
		esac \n \
		mkdir -v $LFS/tools \n \
		groupadd lfs \n \
		useradd -s /bin/bash -g lfs -m -k /dev/null lfs \n \
		echo alpine | passwd lfs --stdin \n \
		chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools} \n \
		case $(uname -m) in \n \
			x86_64) chown -v lfs $LFS/lib64 ;; \n \
		esac \n \
		su - lfs" >> start.sh && \
	chmod +x start.sh
