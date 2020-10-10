#!/bin/bash

#////////////////////////////////////
# ql-uninstaller
# langsung crot
#////////////////////////////////////

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
	$ECMD "$GREEN_BULLET${aCOLOUR[2]}Removing Package ..."
	$ECMD "$GREEN_LINE"
		apt-get purge net-tools qrencode nmap dmidecode lolcat -y ; apt-get autoremove -y
	}

tools_rpm() {
	$ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Removing Package ..."
        $ECMD "$GREEN_LINE"
                yum remove net-tools qrencode ruby nmap dmidecode -y
	}

req() {
        $ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Uninstalling Requirements ..."
        $ECMD "$GREEN_LINE"
                rm /usr/bin/Q | cut -b 100- ; rm /etc/qlauncher-qr | cut -b 100-
	}

docker() {
	$ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Uninstalling Docker ..."
        $ECMD "$GREEN_LINE"
		DOCKR=$(which docker)
			if [[ ! -z $DOCKR ]] ; then
				apt-get purge docker-ce docker-ce-cli -y ; apt-get autoremove -y --purge docker-ce
				rm -rf /var/lib/docker /etc/docker ; rm -rf /etc/apparmor.d/docker ; rm -rf /var/run/docker.sock ; groupdel docker
			else
				$ECMD "$RED_WARN${aCOLOUR[3]}Docker not installed $COLOUR_RESET"
			fi
	}

ql() {
        $ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Uninstalling Qlauncher ..."
        $ECMD "$GREEN_LINE"
			rm -rf /etc/ql
	}

SWAP_DIR="/var/swap"

swabcrod() {
	cp /etc/fstab.factory /etc/fstab ; swapoff $SWAP_DIR
	}

reload() {
	systemctl disable qlauncher ; systemctl stop qlauncher ; rm -rf /etc/systemd/system/qlauncher.service ; systemctl daemon-reload
	}

rpm() {
	tools_rpm ; req ; docker ; ql ; swabcrod ; reload
	}

deb() {
	tools_deb ; req ; docker ; ql ; swabcrod ; reload
	}

#Detect root
if [[ $(id -u) -ne 0 ]] ; then
        $ECMD "$GREEN_WARN${aCOLOUR[3]}Please run as root $COLOUR_RESET"
	exit 1
fi

        #Fedora 31 and 32 can't install
        if cat /etc/os-release | grep ^PRETTY_NAME | grep 32 ; then
	        $ECMD "$RED_WARN${aCOLOUR[3]}Can't install $COLOUR_RESET"
	        exit 1
        fi

        if cat /etc/os-release | grep ^PRETTY_NAME | grep 31 ; then
                $ECMD "$RED_WARN${aCOLOUR[3]}Can't install $COLOUR_RESET"
                exit 1
        fi

#kickoff
  RPM=$(which yum)
  APT=$(which apt-get)

	if [[ ! -z $RPM ]]; then
    		rpm ; Q --about
	elif [[ ! -z $APT ]]; then
    		deb ; Q --about
	else
    		$ECMD "$RED_WARN${aCOLOUR[3]}Can't uninstall $COLOUR_RESET"
    		exit 1
 	fi
