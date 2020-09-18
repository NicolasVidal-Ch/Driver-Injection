#Old IP:
IPRASP=$(ip a | grep '10.1.6' | cut -d ' ' -f6 | cut -d '/' -f1)
echo $IPRASP >> /etc/oldiprasp
#WPA_supplicant:
apt install wpasupplicant

#Download from a driver source: 
git clone https://github.com/cilynx/rtl88x2bu
cd rtl88x2bu/

#Configure for RasPi:
sed -i 's/I386_PC = y/I386_PC = n/' Makefile
sed -i 's/ARM_RPI = n/ARM_RPI = y/' Makefile

#DKMS configuration (compilation and installation):
VER=$(sed -n 's/\PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)
rsync -rvhP ./ /usr/src/rtl88x2bu-${VER}
dkms add -m rtl88x2bu -v ${VER}
dkms build -m rtl88x2bu -v ${VER}
dkms install -m rtl88x2bu -v ${VER}
echo 88x2bu >> /etc/modules

#Variable creation for Wlan1 IP:
#COUNTER=2
#NETWORK=10.1.6
#while [ $COUNTER -lt 254 ]
#do
#   if ping -c1 -w3 $NETWORK.$COUNTER >/dev/null 2>&1
#   then
#   COUNTER=$(( $COUNTER + 1 ))
#   else
#   IPWLAN=$NETWORK.$COUNTER
#   COUNTER=254
#   fi
#done

#WPA_supplicant conf file:
echo country=fr > /etc/wpa_supplicant/wpa_supplicant.conf
echo ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev >> /etc/wpa_supplicant/wpa_supplicant.conf
echo update_config=1 >> /etc/wpa_supplicant/wpa_supplicant.conf
echo network={ >> /etc/wpa_supplicant/wpa_supplicant.conf
echo ssid="\042"TSSRARIEN"\042" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo psk="\042"P455Support"\042" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo } >> /etc/wpa_supplicant/wpa_supplicant.conf

#Change IP address with a variable:
echo auto lo > /etc/network/interfaces
echo iface lo inet loopback >> /etc/network/interfaces
#echo iface eth0 inet dhcp >> /etc/network/interfaces
echo allow-hotplug wlan0 >> /etc/network/interfaces
echo iface wlan0 inet dhcp >> /etc/network/interfaces
echo wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf >> /etc/network/interfaces
echo allow-hotplug wlan1 >> /etc/network/interfaces
echo iface wlan1 inet dhcp >> /etc/network/interfaces
#echo address $IPWLAN >> /etc/network/interfaces
#echo netmask 255.255.255.0 >> /etc/network/interfaces
#echo gateway 10.1.6.1 >> /etc/network/interfaces
echo wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf >> /etc/network/interfaces

#New IP:
#IPWLAN=$(ip route | grep 'wlan1' | cut -d ' ' -f9)


#echo RPI.$IPWLAN > /etc/hostname

#echo 127.0.0.1       localhost > /etc/hosts
#echo 127.0.1.1       RPI.$IPWLAN >> /etc/hosts

#Send IP address on ipraspberry file:
#sed -i -e "s/$IPRASP/$IPWLAN/g" /mnt/servrpi/export/exportrpi/hosts
#echo RPI.$IPWLAN >> /mnt/servrpi/export/exportrpi/hostname

#Download Github NetworkManager:
wget --no-check-certificate -P /etc https://github.com/NicolasVidal-Ch/network/archive/net.tar.gz
tar vxf /etc/net.tar.gz -C /etc
chmod +x /etc/network-net/network.sh

#Create a cron for launch the network script:
echo */2*.*** root sh /etc/network-net/network.sh >> /etc/crontab

#Install Network-Manager:
apt -y install network-manager

#Configuration "NetworkManager.conf":
echo "\n" >> /etc/NetworkManager/NetworkManager.conf
echo [device] >> /etc/NetworkManager/NetworkManager.conf
echo "\n" >> /etc/NetworkManager/NetworkManager.conf
echo wifi.scan-rand-mac-address=no >> /etc/NetworkManager/NetworkManager.conf

#Reboot the pi:
reboot
