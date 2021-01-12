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
MBMENU='/usr/local/mbmenu'
mb_backups="/usr/local/mbbackup/mbscrip-$(date +%d%m%Y%H%M)"
LOG="/usr/local/mbbackup/mbscript_install-$(date +%d%m%Y%H%M).log"
arch=$(uname -i)
spinner="/-\|"
os='ubuntu'
release="$(lsb_release -s -r)"
codename="$(lsb_release -s -c)"
VERBOSE='no'
echo "=========================================================================="
echo "Mac dinh server se duoc cai dat PHP 7.4. Thay doi phien ban PHP bang chuc"
echo "--------------------------------------------------------------------------"
echo "nang [Doi phien ban PHP] trong [Update System (Apache,PHP...)] cua MBScript.  "
echo "--------------------------------------------------------------------------"
echo "PHP versions support: 7.3, 7.2, 7.1, 7.0, 5.6"
echo "--------------------------------------------------------------------------"
echo "MariaDB versions support: 10.5"
cpuname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cpucores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
cpufreq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
svram=$( free -m | awk 'NR==2 {print $2}' )
svhdd=$( df -h | awk 'NR==2 {print $2}' )
svswap=$( free -m | awk 'NR==3 {print $2}' )

########################
# Hỏi trước khi cài đặt#
########################









echo "=========================================================================="
echo "Thong Tin Server:  "
echo "--------------------------------------------------------------------------"
echo "Server Type: $(virt-what | awk 'NR==1 {print $NF}')"
echo "CPU Type: $cpuname"
echo "CPU Core: $cpucores"
echo "CPU Speed: $cpufreq MHz"
echo "Memory: $svram MB"
echo "Disk: $svhdd"
echo "IP: $svip"
echo "=========================================================================="
echo "Dien Thong Tin Cai Dat: "
echo "--------------------------------------------------------------------------"
echo -n "Nhap PhpMyAdmin Port [ENTER]: " 
read svport
if [ "$svport" = "443" ] || [ "$svport" = "3306" ] || [ "$svport" = "465" ] || [ "$svport" = "587" ]; then
	svport="2313"
echo "Phpmyadmin khong the trung voi port cua dich vu khac !"
echo "--------------------------------------------------------------------------"
echo "MBScript se dat phpmyadmin port la 2313"
fi
if [ "$svport" = "" ] ; then
clear
echo "=========================================================================="
echo "$svport khong duoc de trong."
echo "--------------------------------------------------------------------------"
echo "Ban hay kiem tra lai !" 
bash /etc/MBScript/.tmp/MBScript-setup
exit
fi
if ! [[ $svport -ge 100 && $svport -le 65535  ]] ; then  
clear
echo "=========================================================================="
echo "$svport khong hop le!"
echo "--------------------------------------------------------------------------"
echo "Port hop le la so tu nhien nam trong khoang (100 - 65535)."
echo "--------------------------------------------------------------------------"
echo "Ban hay kiem tra lai !" 
echo "-------------------------------------------------------------------------"
read -p "Nhan [Enter] de tiep tuc ..."
clear

# Define software versions

MB_INSTALL_VER='1.0.0'
pma_v='5.0.4'
php_v=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0")
fpm_v="7.4"
mariadb_v="10.5"

