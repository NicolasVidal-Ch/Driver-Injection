# Install prereqs
apt install -y bc build-essential dkms rsync raspberrypi-kernel-headers

# Download from a driver source 
git clone https://github.com/cilynx/rtl88x2bu
cd rtl88x2bu/

# Configure for RasPi
sed -i 's/I386_PC = y/I386_PC = n/' Makefile
sed -i 's/ARM_RPI = n/ARM_RPI = y/' Makefile

# DKMS configuration (compilation and installation)
VER=$(sed -n 's/\PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)
rsync -rvhP ./ /usr/src/rtl88x2bu-${VER}
dkms add -m rtl88x2bu -v ${VER}
dkms build -m rtl88x2bu -v ${VER}
dkms install -m rtl88x2bu -v ${VER}
echo rtl88x2bu >> /etc/modules

#Création d'une varible pour récupérer l'ID de la carte WI-FI:
ID=$(ip a | grep '4:' | cut -d ' ' -f2 | cut -d ':' -f1)

#Create a variable for change IP:
COUNTER=1
NETWORK=10.1.6
while [ $COUNTER -lt 254 ]
do
   if ping -c1 -w3 $NETWORK.$COUNTER >/dev/null 2>&1
   then
   COUNTER=$(( $COUNTER + 1 ))
   else
   IP=$NETWORK.$COUNTER
   COUNTER=254
   fi
done

#Change IP address with a variable:
echo auto $ID >> /etc/network/interfaces
echo iface $ID inet static >> /etc/network/interfaces
echo  wpa-ssid TSSRARIEN >> /etc/network/interfaces
echo  wpa-psk P455Support >> /etc/network/interfaces
echo	address $IP >> /etc/network/interfaces
echo	netmask 255.255.255.0 >> /etc/network/interfaces
echo	gateway 10.1.6.1 >> /etc/network/interfaces

#restart netwoking.service:
systemctl restart networking.service
