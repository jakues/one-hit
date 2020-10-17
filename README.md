<h1 align="center">1 click install Qlauncher</h1>

This scripts automates the installation process for [Qlauncher](https://github.com/poseidon-network/qlauncher-linux).
It automatically downloads and installs the following packages:

* docker-ce
* net-tools
* lolcat 😋
* qrencode
* Qlauncher (Latest)


# [ Prerequisites ]
The installation scripts require the following:

* The machine operating system Ubuntu, Debian, Centos, RHEL, Fedora on x86.
* For raspberry pi need at least model 3B, 3B+, 4B with operating system :
	* [Raspberry Pi OS](https://downloads.raspberrypi.org/raspios_lite_armhf_latest)
	* [DietPi](https://dietpi.com/downloads/images/DietPi_RPi-ARMv6-Buster.7z)
	* [Ubuntu server 32 bit](https://ubuntu.com/download/raspberry-pi)
* Run as root user.


# [ Install ]
* Use this command to install Qlauncher on x86
	* `curl -sSL https://git.io/JUxCs | bash`
* Use this command to install Qlauncher on Raspberry Pi
	* To install `curl -sSL https://git.io/JTcnm | bash`
	* Then `reboot` to enable cgroupfs
* Script usage
	* `Q --help`


# [ Uninstall ]
* Use this command to install Qlauncher
	* `curl -sSL https://git.io/JTfK7 | bash`
* Script usage
	* `reboot`
