#!/bin/bash

#////////////////////////////////////
# ql-installer
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
	$ECMD "$GREEN_BULLET${aCOLOUR[2]}Updating Package ..."
	$ECMD "$GREEN_LINE"

		apt-get update -qq -y ; apt-get upgrade -qq -y ; apt-get install wget net-tools nmap dmidecode lolcat -qq -y
	}

tools_rpm() {
	$ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Updating Package ..."
        $ECMD "$GREEN_LINE"

                yum update -y ; yum upgrade -y ; yum install epel-release wget net-tools ruby nmap dmidecode unzip -y
	}

req() {
        $ECMD "$GREEN_LINE"
        $ECMD "$GREEN_BULLET${aCOLOUR[2]}Installing Requirements ..."
        $ECMD "$GREEN_LINE"

                wget https://git.io/JUEI8 -O ql.tar.gz ; wget -O /usr/bin/Q https://git.io/JUxnc ; chmod +x /usr/bin/Q
	}

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

swabcrod() {
	chmod 600 $SWAP_DIR
	mkswap $SWAP_DIR
	swapon $SWAP_DIR
	echo "$SWAP_DIR none swap defaults 0 0" >> /etc/fstab
	}

cekswab() {
	if ( $MEMM | grep "Size: 1024 MB" ) ; then
		fallocate -l 2069M $SWAP_DIR ; swabcrod
	elif ( $MEMM | grep "Size: 2048 MB" ) ; then
		fallocate -l 1069M $SWAP_DIR ; swabcrod
	elif ( $MEMM | grep "Size: 4096 MB" ) ; then
		fallocate -l 769M $SWAP_DIR ; swabcrod
	else
		fallocate -l 469M $SWAP_DIR ; swabcrod
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

rpm() {
	tools_rpm ; req ; lolcat ; docker ; ql ; onboot ; systemctl stop docker ; systemctl start docker ; systemctl enable docker ; swabtes ; reload >> install.log
	}

deb() {
	tools_deb ; req ; docker ; ql ; onboot ; ln -s /usr/games/lolcat /usr/bin/lolcat ; swabtes ; reload >> install.log
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
    		$ECMD "$RED_WARN${aCOLOUR[3]}Can't install $COLOUR_RESET"
    		exit 1 ;
 	fi
