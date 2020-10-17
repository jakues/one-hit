#!/usr/bin/env bash

#///////////////////////////////////////
#//////////////////////////////////////
#////////qlauncher-installer//////////
#////////////////////////////////////
#///////////////////////////////////

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

#install requirements
tools() {
	$ECMD "$GREEN_LINE"
	$ECMD "$GREEN_BULLET${aCOLOUR[2]}Updating Package ..."
	$ECMD "$GREEN_LINE"
		apt-get update -qq -y ; apt-get upgrade -qq -y ; apt-get install wget net-tools qrencode nmap dmidecode lolcat -qq -y
	}

req() {
        $ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Installing Requirements ..."
        $ECMD "$GREEN_LINE"
                wget https://git.io/JUEI8 -O ql.tar.gz ; wget -O /usr/bin/Q https://git.io/JUxnc ; chmod +x /usr/bin/Q ; echo -e "NAS-QNAP-$(cat /etc/machine-id)" | tee /etc/qlauncher-qr
	}

#install docker
docker() {
	$ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Installing Docker ..."
        $ECMD "$GREEN_LINE"
		DOCKR=$(which docker)
			if [[ ! -z $DOCKR ]] ; then
				$ECMD "$RED_WARN${aCOLOUR[3]}Docker installed $COLOUR_RESET"
			else
				curl -sSL https://get.docker.com | sh
			fi
	}

#install qlauncher
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

reload() { systemctl enable qlauncher ; systemctl start qlauncher ; systemctl daemon-reload }

cgroup_raspbian() {
	CMDLINE_RASPBIAN=/boot/cmdline.txt
	sudo sed -i -e 's/rootwait/cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 rootwait/' $CMDLINE_RASPBIAN
	}

cgroup_ubuntu() {
	CMDLINE_UBUNTU=/boot/firmware/cmdline.txt
	sudo sed -i -e 's/rootwait/cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 rootwait/' $CMDLINE_UBUNTU
	}

#Detect root
	if [[ $(id -u) -ne 0 ]] ; then
		$ECMD "$GREEN_WARN${aCOLOUR[3]}Please run as root $COLOUR_RESET"
		exit 1
	fi

#Checking if user run on rpi
		MODELO=$(uname -m)
		if [ "${MODELO}" != "armv7l" ]; then
			$ECMD "$RED_WARN${aCOLOUR[3]}This script is only intended to run on ARM devices.$COLOUR_RESET"
			exit 1
		elif [[ "${MODELO}" == *"aarch64"* ]] ; then
			$ECMD "$RED_WARN${aCOLOUR[3]}Currently Qlauncher doesn't support arm64.$COLOUR_RESET"
		fi

#kickoff
		if [[ "$(tr -d '\0' < /proc/device-tree/model)" == *"Raspberry Pi"* ]]; then
			tools ; req ; docker ; ql ; onboot ; reload ; Q --about
		else
			$ECMD "$RED_WARN${aCOLOUR[3]}This is not a Raspberry Pi.$COLOUR_RESET"
			exit 1
		fi

#enable cgroup
	if $(ls /boot/cmdline.txt | cut -b 6969-) ; then
		if $(cat /boot/cmdline.txt | grep "cgroup") ; then
			$ECMD "$RED_WARN${aCOLOUR[3]}Cgroupfs already enabled.$COLOUR_RESET"
			exit 1
		else
			cgroup_raspbian
		fi
	elif $(ls /boot/firmware/cmdline.txt | cut -b 6969-) ; then
		if $(cat /boot/cmdline.txt | grep "cgroup") ; then
			$ECMD "$RED_WARN${aCOLOUR[3]}Cgroupfs already enabled.$COLOUR_RESET"
			exit 1
		else
			cgroup_ubuntu
		fi
	else
		$ECMD "$RED_WARN${aCOLOUR[3]}Can't enable cgroupfs.$COLOUR_RESET"
		$ECMD "$RED_WARN${aCOLOUR[3]}Please enable manually.$COLOUR_RESET"
	fi

