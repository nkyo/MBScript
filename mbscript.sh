#!/bin/sh

clear
echo "#    __  __       _   ____               _   _ ______ _______ #"
echo "#   |  \/  |     | | |  _ \             | \ | |  ____|__   __|#"
echo "#   | \  / | __ _| |_| |_) | __ _  ___  |  \| | |__     | |   #"
echo "#   | |\/| |/ _  | __|  _ < / _  |/ _ \ | .   |  __|    | |   #"
echo "#   | |  | | (_| | |_| |_) | (_| | (_) _| |\  | |____   | |   #"
echo "#   |_|  |_|\__,_|\__|____/ \__,_|\___(_|_| \_|______|  |_|   #"
echo ""
echo "   		MatBao Script For Ubuntu Server					"
echo "-------> Dang chuan bi cai dat script len may chu..."
echo " Dang kiem tra cac goi da duoc cai dat tren may chu, vui long cho..."

sleep 3

if [ $(id -u) != "0" ]; then
    echo "Error: Ban can quyen sudo (root) de cai dat script!"
    exit
fi
if [ -f /var/cpanel/cpanel.config ]; then
clear
echo "Ban da cai dat cPanel, ban can go bo cPanel de cai dat MBScript."
echo "Neu ban muon cai dat MBScript, hay rebuild / reloadOS lai he dieu hanh Ubuntu 64bit."
echo "Tam biet !"
exit
fi

if [ -f /etc/psa/.psa.shadow ]; then
clear
echo "Ban da cai dat Plesk, ban can go bo Plesk de cai dat MBScript."
echo "Neu ban muon cai dat MBScript, hay rebuild / reloadOS lai he dieu hanh Ubuntu 64bit."
echo "Tam biet !"
exit
fi

if [ -f /etc/init.d/directadmin ]; then
clear
echo "Ban da cai dat DirectAdmin, ban can go bo DirectAdmin de cai dat MBScript."
echo "Neu ban muon cai dat MBScript, hay rebuild / reloadOS lai he dieu hanh Ubuntu 64bit."
echo "Tam biet !"
exit
fi

if [ -f /etc/init.d/webmin ]; then
clear
echo "Ban da cai dat webmin, ban can go bo webmin de cai dat MBScript."
echo "Neu ban muon cai dat MBScript, hay rebuild / reloadOS lai he dieu hanh Ubuntu 64bit."
echo "Tam biet !"
exit
fi

echo "Luu y! De cai dat MBscript, Apache va MySQL / MariaDB se duoc go cai dat..."
sleep 2
echo " Khi go cai dat dong nghia voi viec toan bo du lieu website / config / Database se bi xoa. Vui long can nhac sao luu du lieu va doc ky bai viet huong dan sau"
sleep 2
echo "http://wiki.matbao.net/bai-viet-huong-dan-cai-dat-wiki"
sleep 2

echo ""
read -n1 -s -r -p $'Vui long bam phim y de xac nhan tiep tuc...\n' key

if [ "$key" != 'y' ]; then
echo "Huy bo cai dat."
exit
fi
echo "Dang tien hanh go cai dat Apache / Nginx va MySQL / MariaDB..."
apt-get remove apache2 -y && apt-get remove nginx -y && apt-get remove mysqld mariadb -y
echo "Go cai dat hoan tat, bat dau cai dat thu vien MBScript..."

##----------------------------------Bat Dau Qua trinh cai dat MB SCript -------------------------------------##

export PATH=$PATH:/sbin
export DEBIAN_FRONTEND=noninteractive
VERSION='ubuntu'
MB='/usr/local/mbmenu'
LOG="/usr/local/mbbackup/mbscript_install-$(date +%d%m%Y%H%M).log"
memory=$(grep 'MemTotal' /proc/meminfo |tr ' ' '\n' |grep [0-9])
mb_backups="/usr/local/mbbackup/mbscrip-$(date +%d%m%Y%H%M)"
arch=$(uname -i)
spinner="/-\|"
os='ubuntu'
release="$(lsb_release -s -r)"
codename="$(lsb_release -s -c)"
HESTIA_INSTALL_DIR="$MB/install/deb"
VERBOSE='no'

########################
# Hỏi trước khi cài đặt#
########################



PHPSELECT=form-ask

# Define software versions

MB_INSTALL_VER='1.0.0'
pma_v='5.0.4'
php_v=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0")
fpm_v="7.4"
mariadb_v="10.5"

