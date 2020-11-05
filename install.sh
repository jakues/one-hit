#!/bin/bash

# Description	: Script to install Qlauncher.
# Author		: Rill (jakueenak@gmail.com)
# Telegram		: t.me/pethot
# Version		: beta

ECMD="echo -e"
COLOUR_RESET='\e[0m'
aCOLOUR=(
		'\e[1;33m'	# Yellow
		'\e[1m'		# Bold white
		'\e[1;32m'	# Green
		'\e[1;31m'  # Red
	)

	GREEN_LINE="${aCOLOUR[0]}──────────────────────────────────────────────────────────$COLOUR_RESET"
	GREEN_BULLET="${aCOLOUR[2]}  [+] $COLOUR_RESET"
	GREEN_WARN="${aCOLOUR[2]}  [!] $COLOUR_RESET"
	RED_WARN="${aCOLOUR[3]}  [!] $COLOUR_RESET"

tools_deb() {
	$ECMD "$GREEN_LINE"
	$ECMD "$GREEN_BULLET${aCOLOUR[2]}Updating Package ..."
	$ECMD "$GREEN_LINE"
		apt-get update -qq -y ; apt-get upgrade -qq -y ; apt-get install wget net-tools qrencode nmap dmidecode lolcat -qq -y
	}

tools_rpm() {
	$ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Updating Package ..."
        $ECMD "$GREEN_LINE"
                yum update -y ; yum upgrade -y ; yum install epel-release wget net-tools qrencode ruby nmap dmidecode unzip -y
	}

req() {
        $ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Installing Requirements ..."
        $ECMD "$GREEN_LINE"
                wget https://git.io/JUEI8 -O ql.tar.gz ; wget -O /usr/bin/Q https://git.io/JUxnc ; chmod +x /usr/bin/Q ; $ECMD "NAS-QNAP-$(cat /etc/machine-id)" | tee /etc/qlauncher-qr | cut -b 45- ; ln -s /usr/games/lolcat /usr/bin/lolcat
	}

docker() {
	$ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Installing Docker ..."
        $ECMD "$GREEN_LINE"
			if [[ ! -z $(which docker) ]] ; then
				$ECMD "$RED_WARN${aCOLOUR[3]}Docker installed $COLOUR_RESET"
			else
				curl -sSL https://get.docker.com | bash
			fi
	}

ql() {
        $ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Installing Qlauncher ..."
        $ECMD "$GREEN_LINE"
			mkdir -p /etc/ql ; tar -vxzf ql.tar.gz -C /etc/ql ; rm ql.tar.gz
	}

onboot() {
cat > /etc/systemd/system/qlauncher.service << EOF
[Unit]
Description=qlauncher.service
[Service]
Type=simple
ExecStart=/etc/ql/qlauncher.sh start
ExecStop=/etc/ql/qlauncher.sh stop
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
	}

SWAP_DIR="/var/swap"
MEMM="dmidecode --type memory"

swabb() {
	cp /etc/fstab /etc/fstab.factory
	chmod 600 $SWAP_DIR
	mkswap $SWAP_DIR
	swapon $SWAP_DIR
	echo "$SWAP_DIR none swap defaults 0 0" >> /etc/fstab
	}

cekswab() {
	if ( $MEMM | grep "Size: 1024 MB" ) ; then
		fallocate -l 2069M $SWAP_DIR ; swabb
	elif ( $MEMM | grep "Size: 2048 MB" ) ; then
		fallocate -l 1069M $SWAP_DIR ; swabb
	elif ( $MEMM | grep "Size: 4096 MB" ) ; then
		fallocate -l 769M $SWAP_DIR ; swabb
	else
		fallocate -l 469M $SWAP_DIR ; swabb
	fi
	}

reload() {
	systemctl enable qlauncher ; systemctl start qlauncher ; systemctl daemon-reload
	}

lolcat() {
	wget https://github.com/busyloop/lolcat/archive/master.zip ; unzip master.zip ; cd lolcat-master/bin ; gem install lolcat ; ln -s /usr/games/lolcat /usr/bin/lolcat ; cd ; rm -rf lolcat-master master.zip
	}

swabtes() {
	if  ( 	[ "$(free | awk '/^Swap:/ { print $2 }')" = "0" ] ; [ "$(free --bytes | awk '/^Swap:/ { print $2 }')" -gt 2147483648 ] ) ;
		[ "$(awk '/MemAvailable:/ { print $2 }' /proc/meminfo)" -gt "$(free | awk '/Swap:/ { print $3 }')" ] ; then
		$ECMD "$GREEN_WARN${aCOLOUR[2]}Swap not found$COLOUR_RESET"
		cekswab
	else
		$ECMD "$RED_WARN${aCOLOUR[2]}Swap found$COLOUR_RESET"
	fi
	}

CMDLINE_RASPBIAN=/boot/cmdline.txt
CMDLINE_UBUNTU=/boot/firmware/cmdline.txt
MODELO=$(uname -m)

cgroup_raspbian() {
	sed -i -e 's/rootwait/cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 rootwait/' $CMDLINE_RASPBIAN
	}

cgroup_ubuntu() {
	sed -i -e 's/rootwait/cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 rootwait/' $CMDLINE_UBUNTU
	}

cgroupfs() {
	if $(cat /etc/os-release | grep debian | cut -b 69-) ; then
		if $(cat /boot/cmdline.txt | grep "cgroup" | cut -b 696-) ; then
			$ECMD "$RED_WARN${aCOLOUR[2]}Cgroupfs already enabled.$COLOUR_RESET"
		else
			cgroup_raspbian
        fi
	elif $(cat /etc/os-release | grep ubuntu | cut -b 69-) ; then
        if $(cat /boot/cmdline.txt | grep "cgroup" | cut -b 696-) ; then
			$ECMD "$RED_WARN${aCOLOUR[2]}Cgroupfs already enabled.$COLOUR_RESET"
        else
          cgroup_ubuntu
        fi
	else
		$ECMD "$RED_WARN${aCOLOUR[3]}Can't enable cgroupfs.$COLOUR_RESET"
		$ECMD "$RED_WARN${aCOLOUR[3]}Please enable manually.$COLOUR_RESET"
	fi
	}

check_arch_rpi() {
	if [ "${MODELO}" != "armv7l" ]; then
		$ECMD "$RED_WARN${aCOLOUR[3]}This script is only intended to run on ARM devices.$COLOUR_RESET"
		exit 1
	elif [[ "${MODELO}" == *"aarch64"* ]] ; then
		$ECMD "$RED_WARN${aCOLOUR[3]}Currently Qlauncher doesn't support arm64.$COLOUR_RESET"
	fi
	}

reboot_rpi() {
	read -p "  [+] Reboot now to enable cgroupfs ? [y/N]" -n 1 -r
		if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
			$ECMD "\n $COLOUR_RESET" ; exit 1
		else
			$ECMD "$COLOUR_RESET" ; reboot
		fi
	}

rpm() { tools_rpm ; lolcat ; req ; docker ; ql ; onboot ; systemctl restart docker ; systemctl enable docker ; swabtes ; reload ; }

deb() { tools_deb ; req ; docker ; ql ; onboot ; swabtes ; reload ; }

rpi() { tools_deb ; req ; docker ; ql ; onboot ; ln -s /usr/games/lolcat /usr/local/bin/lolcat ; ln -s /usr/bin/Q /usr/local/bin/Q ; reload ; cgroupfs ; }
	
RPM=$(which yum)
APT=$(which apt-get)
	
regular() {
	if [[ ! -z $RPM ]]; then
    		rpm ; Q --about
	elif [[ ! -z $APT ]]; then
    		deb ; Q --about
	else
    		$ECMD "$RED_WARN${aCOLOUR[3]}Can't install $COLOUR_RESET"
    		exit 1
 	fi
	}
	
#Detect root
if [[ $(id -u) -ne 0 ]] ; then
        $ECMD "$GREEN_WARN${aCOLOUR[3]}Please run as root $COLOUR_RESET"
	exit 1
fi

#Fedora 31 and 32 can't install due docker-ce issue
if cat /etc/os-release | grep ^PRETTY_NAME | grep 32 ; then
	$ECMD "$RED_WARN${aCOLOUR[3]}Can't install $COLOUR_RESET"
	exit 1
fi

if cat /etc/os-release | grep ^PRETTY_NAME | grep 31 ; then
	$ECMD "$RED_WARN${aCOLOUR[3]}Can't install $COLOUR_RESET"
	exit 1
fi

#Detect architecture
if [[ "${MODELO}" == *"x86_64"* ]] ; then
	regular
elif [[ "$(tr -d '\0' < /proc/device-tree/model)" == *"Raspberry Pi"* ]] ; then
	check_arch_rpi ; rpi ; reboot_rpi
fi
