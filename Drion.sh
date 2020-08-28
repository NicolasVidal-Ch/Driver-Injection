# Install prereqs
apt install -y hostapd bc build-essential dkms rsync git

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
