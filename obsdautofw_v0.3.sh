#!/bin/sh

#Author Tyler K Monroe aka tman904 date 6/9/2018 @8:56PM

#init function
init() {

while true

	do
		echo "Please enter install, remove or custom\n"
		read action

		#check action
		if [ "$action" == "install" ] ; then
		  install

		elif [ "$action" == "remove" ] ; then
			remove

		elif [ "$action" == "custom" ] ; then
			custom

		else

		clear

		fi
	done


}

#install function
install() {

  #Are we on OpenBSD?
	curos=`uname -a |grep -i openbsd |awk '{ print $1}'`

	  #check current os
		if [ "$curos" == "OpenBSD" ] ; then

					echo "We are on $curos starting install.\n"
			else
				  echo "Sorry but we don't appear to be running on OpenBSD we can't continue the install.\n"
					echo "Check here https://www.openbsd.org"
					exit 0

		fi

	#check if we're root
	usr=`whoami`

	#check usr
	if [ "$usr" == "root" ] ; then
		echo ""
	else
	echo "Grab some starbucks $usr is not root this program needs root to run\n"

	exit 0

	fi

	#have we been installed
	if [ -f /root/obsdafw.installed ] ; then

	echo "We are already installed\n"
	exit 0

	fi

	#leave a footprint
	touch /root/obsdafw.installed


	#get interfaces from user
	echo "Please enter desired lan interface\n"
	read lanif
	echo "Please enter desired wan interface\n"
	read wanif

	#setup those interfaces
	echo "inet 192.168.10.1 255.255.255.0" >/etc/hostname.$lanif
	echo "dhcp" >/etc/hostname.$wanif

	#set ip routing
	echo "net.inet.ip.forwarding=1" >/etc/sysctl.conf

	#setup pf.conf
	cp /etc/pf.conf /etc/pf.conf.back
	echo "int=\"$lanif\"\n" >/etc/pf.conf
	echo "ext=\"$wanif\"\n" >>/etc/pf.conf
	echo "set skip on lo0\n" >>/etc/pf.conf
	echo "set block-policy drop\n" >>/etc/pf.conf
	echo "" >>/etc/pf.conf
	echo "block drop all" >>/etc/pf.conf
	echo "pass in on \$int from \$int:network to any keep state\n" >>/etc/pf.conf
	echo "pass out on \$ext from \$int:network to any nat-to (\$ext) keep state\n" >>/etc/pf.conf
	echo "pass out on \$ext from \$ext:network to any keep state\n" >>/etc/pf.conf

	#setup dhcpd.conf
	echo "option domain-name \"obsd\";\n" >/etc/dhcpd.conf
	echo "option domain-name-servers 4.2.2.1, 4.2.2.2;\n" >>/etc/dhcpd.conf
	echo "subnet 192.168.10.0 netmask 255.255.255.0 {\n" >>/etc/dhcpd.conf
	echo "range 192.168.10.100 192.168.10.200;\n" >>/etc/dhcpd.conf
	echo "option routers 192.168.10.1;\n" >>/etc/dhcpd.conf
	echo "}" >>/etc/dhcpd.conf

	#start dhcpd on boot
	rcctl enable dhcpd

	#disable smtpd and sndiod
	rcctl disable smtpd
	rcctl disable sndiod

	#Make backup of configs
	mkdir /root/openbsdafw_backup
	cp /etc/hostname.* /root/openbsdafw_backup
	cp /etc/pf.conf /root/openbsdafw_backup
	cp /etc/dhcpd.conf /root/openbsdafw_backup
	cp /etc/sysctl.conf /root/openbsdafw_backup
	tar cf /root/openbsdafw_backup.tar /root/openbsdafw_backup

	echo "########################################################################\n"
	echo "A tar archive of the config files this program has made is located here\n"
	echo "/root/openbsdafw_backup.tar"
	echo "########################################################################\n"


	echo "ALL DONE!!!!!!!!\n"
	echo "BYE BYE!!!!!!!!!"
	sleep 2
	reboot
}

remove() {


	#Are we on OpenBSD?
	curos=`uname -a |grep -i openbsd |awk '{ print $1 }'`

		#check current os
		if [ "$curos" == "OpenBSD" ] ; then

					echo "We are on $curos starting removal.\n"
			else
					echo "Sorry but we don't appear to be running on OpenBSD we can't continue the removal.\n"
					echo "Check here https://www.openbsd.org"
					exit 0

		fi


	#check if we're root
	usr=`whoami`

	#check usr
	if [ "$usr" == "root" ] ; then
		echo ""
	else
	echo "Grab some starbucks $usr is not root this program needs root to run\n"

	exit 0

	fi

	#are we installed
	if [ -f /root/obsdafw.installed ] ; then

	#reset to default state
	rm /etc/hostname.*
	pfctl -F all
	cp /etc/pf.conf.back /etc/pf.conf
	rcctl disable dhcpd
	rcctl enable smtpd
	rcctl enable sndiod
	rm /etc/dhcpd.conf
	rm /etc/sysctl.conf
	rm /root/obsdafw.installed
	rm -rf /root/openbsdafw_backup*

	echo "ALL DONE!!!!!!!!\n"
	echo "BYE BYE!!!!!!!!!"
	sleep 2
	reboot

	else

	clear
	echo "we haven't been installed yet may I suggest starbucks."


	fi

}

custom() {


	#Are we on OpenBSD?
	curos=`uname -a |grep -i openbsd |awk '{ print $1 }'`

		#check current os
		if [ "$curos" == "OpenBSD" ] ; then

					echo "We are on $curos starting custom install.\n"
			else
					echo "Sorry but we don't appear to be running on OpenBSD we can't continue the custom install.\n"
					echo "Check here https://www.openbsd.org"
					exit 0

		fi



		#check if we're root
	usr=`whoami`

	#check usr
	if [ "$usr" == "root" ] ; then
		echo ""
	else
	echo "Grab some starbucks $usr is not root this program needs root to run\n"

	exit 0

	fi

	#have we been installed
	if [ -f /root/obsdafw.installed ] ; then

	echo "We are already installed\n"
	exit 0

	fi

	#leave a footprint
	touch /root/obsdafw.installed


	#get interfaces from user
	echo "Please enter desired lan interface\n"
	read lanif
	echo "Please enter lan interface IP Address\n"
	read lanifip
	echo "Please enter lan interface NETMASK\n"
	read lanifmask

	echo "Please enter desired wan interface\n"
	read wanif

	echo "Do you have a static IP on your wan? yes/no\n"
	read ans
	if [ "$ans" == "yes" ] ; then

		echo "Please enter wan interface IP Address\n"
		read wanifip
		echo "Please enter wan interface NETMASK\n"
		read wanifmask
		echo "Please enter wan interface default gateway\n"
		read wangw

		echo "inet $wanifip $wanifmask" >/etc/hostname.$wanif
		echo "" >>/etc/hostname.$wanif
		echo "!route add default $wangw" >>/etc/hostname.$wanif

	else

		echo "dhcp" >/etc/hostname.$wanif


	fi

	#setup those interfaces
	echo "inet $lanifip $lanifmask" >/etc/hostname.$lanif

	#set ip routing
	echo "net.inet.ip.forwarding=1" >/etc/sysctl.conf

	#setup pf.conf
	cp /etc/pf.conf /etc/pf.conf.back
	echo "int=\"$lanif\"\n" >/etc/pf.conf
	echo "ext=\"$wanif\"\n" >>/etc/pf.conf
	echo "set skip on lo0\n" >>/etc/pf.conf
	echo "set block-policy drop\n" >>/etc/pf.conf
	echo "" >>/etc/pf.conf
	echo "block drop all" >>/etc/pf.conf
	echo "pass in on \$int from \$int:network to any keep state\n" >>/etc/pf.conf
	echo "pass out on \$ext from \$int:network to any nat-to (\$ext) keep state\n" >>/etc/pf.conf
	echo "pass out on \$ext from \$ext:network to any keep state\n" >>/etc/pf.conf


	#setup dhcpd.conf

	echo "Time to setup the dhcp server\n"
	echo "Please enter lan interfaces network id/subnet id\n"
	read netid
	echo "Please enter lan dhcp pool start range\n"
	read dhcpstart
	echo "Please enter lan dhcp pool end range\n"
	read dhcpend
	echo "Please enter lan domain name\n"
	read domain
	echo "Please enter lan dns servers \"X.X.X.X, X.X.X.X\""
	read dnsserv

	echo "option domain-name \"$domain\";\n" >/etc/dhcpd.conf
	echo "option domain-name-servers $dnsserv;\n" >>/etc/dhcpd.conf
	echo "subnet $netid netmask $lanifmask {\n" >>/etc/dhcpd.conf
	echo "range $dhcpstart $dhcpend;\n" >>/etc/dhcpd.conf
	echo "option routers $lanifip;\n" >>/etc/dhcpd.conf
	echo "}" >>/etc/dhcpd.conf

	#start dhcpd on boot
	rcctl enable dhcpd

	#disable smtpd and sndiod
	rcctl disable smtpd
	rcctl disable sndiod


	#Make backup of configs
	mkdir /root/openbsdafw_backup
	cp /etc/hostname.* /root/openbsdafw_backup
	cp /etc/pf.conf /root/openbsdafw_backup
	cp /etc/dhcpd.conf /root/openbsdafw_backup
	cp /etc/sysctl.conf /root/openbsdafw_backup
	tar cf /root/openbsdafw_backup.tar /root/openbsdafw_backup

	echo "########################################################################\n"
	echo "A tar archive of the config files this program has made is located here\n"
	echo "/root/openbsdafw_backup.tar"
	echo "########################################################################\n"

	echo "ALL DONE!!!!!!!!\n"
	echo "BYE BYE!!!!!!!!!"
	sleep 2
	reboot

}

init
