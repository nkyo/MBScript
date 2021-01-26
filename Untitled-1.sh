prompt="Nhap lua chon cua ban: "
options=( "Cai Dat VPSSIM Cho VPS Ngay Bay Gio" "Kiem Tra - Test VPS Nay")
PS3="$prompt"
select opt in "${options[@]}"; do

    case "$REPLY" in
    1) luachon="caidatvpssim"; break;;
    2) luachon="check"; break;;
    0) luachon="thoat"; break;;
    *) echo "Ban nhap sai ! Ban vui long chon so trong danh sach";continue;;
    esac
done
if [ "$luachon" = "caidatvpssim" ]; then
echo "========================================================================="
echo "OK, Please wait ...."; sleep 3


ranus=`date |md5sum |cut -c '1-3'`
checktruenumber='^[0-9]+$'
moduledir=/usr/local/vpssim
opensslversion=openssl-1.0.2o
zlibversion=zlib-1.2.11
kiemtraemail3="^(([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~])+\.)*[-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+@\w((-|\w)*\w)*\.(\w((-|\w)*\w)*\.)*\w{2,24}$";
svip=$(wget http://ipecho.net/plain -O - -q ; echo)
###################################################################################################
###################################################################################################

if [ -f /home/vpssim.conf ]; then
clear
echo "========================================================================="
echo "========================================================================="
echo "Your Server is installed VPSSIM"
echo "-------------------------------------------------------------------------"
echo "Use command [ vpssim ] to access VPSSIM menu"
echo "-------------------------------------------------------------------------"
echo "Bye !"
echo "========================================================================="
echo "========================================================================="
rm -rf install*
exit
fi

echo "=========================================================================="
echo "Mac dinh server se duoc cai dat PHP 7.1. Thay doi phien ban PHP bang chuc"
echo "--------------------------------------------------------------------------"
echo "nang [Change PHP Version] trong [Update System (Nginx,PHP...)] cua VPSSIM.  "
echo "--------------------------------------------------------------------------"
echo "PHP versions support: 7.3, 7.2, 7.1, 7.0, 5.6, 5.5 & 5.4"
echo "--------------------------------------------------------------------------"
echo "MariaDB versions support: 10.3, 10.2, 10.1 & 10.0"
cpuname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cpucores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
cpufreq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
svram=$( free -m | awk 'NR==2 {print $2}' )
svhdd=$( df -h | awk 'NR==2 {print $2}' )
svswap=$( free -m | awk 'NR==3 {print $2}' )
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
echo "VPSSIM se dat phpmyadmin port la 2313"
fi
if [ "$svport" = "" ] ; then
clear
echo "=========================================================================="
echo "$svport khong duoc de trong."
echo "--------------------------------------------------------------------------"
echo "Ban hay kiem tra lai !" 
bash /etc/vpssim/.tmp/vpssim-setup
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
bash /etc/vpssim/.tmp/vpssim-setup
exit
fi 
echo "--------------------------------------------------------------------------"
echo -n "Nhap dia chi email quan ly [ENTER]: " 
read vpssimemail
if [ "$vpssimemail" = "" ]; then
clear
echo "=========================================================================="
echo "Ban nhap sai, vui long nhap lai!"
echo "-------------------------------------------------------------------------"
read -p "Nhan [Enter] de tiep tuc ..."
clear
bash /etc/vpssim/.tmp/vpssim-setup
exit
fi

if [[ ! "$vpssimemail" =~ $kiemtraemail3 ]]; then
clear
echo "=========================================================================="
echo "$vpssimemail co le khong dung dinh dang email!"
echo "--------------------------------------------------------------------------"
echo "Ban vui long thu lai  !"
echo "-------------------------------------------------------------------------"
read -p "Nhan [Enter] de tiep tuc ..."
clear
bash /etc/vpssim/.tmp/vpssim-setup
exit
fi
echo "-------------------------------------------------------------------------"
echo "Mat khau bao ve phpMyAdmin toi thieu 8 ki tu va chi dung chu cai va so."
echo "-------------------------------------------------------------------------"
echo -n "Nhap mat khau bao ve phpMyAdmin [ENTER]: " 
read matkhaubv
if [[ ! ${#matkhaubv} -ge 8 ]]; then
clear
echo "========================================================================="
echo "Mat khau bao ve phpMyAdmin toi thieu phai co 8 ki tu."
echo "-------------------------------------------------------------------------"
echo "Ban vui long thu lai !"
echo "-------------------------------------------------------------------------"
read -p "Nhan [Enter] de tiep tuc ..."
clear


ash /etc/vpssim/.tmp/vpssim-setup
exit
fi  

checkpass="^[a-zA-Z0-9_][-a-zA-Z0-9_]{0,61}[a-zA-Z0-9_]$";
if [[ ! "$matkhaubv" =~ $checkpass ]]; then
clear
echo "========================================================================="
echo "Ban chi duoc dung chu cai va so de dat mat khau !"
echo "-------------------------------------------------------------------------"
echo "Ban vui long thu lai !"
echo "-------------------------------------------------------------------------"
read -p "Nhan [Enter] de tiep tuc ..."
clear
bash /etc/vpssim/.tmp/vpssim-setup
exit
fi   
echo "-------------------------------------------------------------------------"
echo "Mat khau root MySQL toi thieu 8 ki tu va chi su dung chu cai va so."
echo "-------------------------------------------------------------------------"
echo -n "Nhap mat khau root MySQL [ENTER]: " 
read passrootmysql
if [[ ! ${#passrootmysql} -ge 8 ]]; then
clear
echo "========================================================================="
echo "Mat khau tai khoan root MySQL toi thieu phai co 8 ki tu."
echo "-------------------------------------------------------------------------"
echo "Ban vui long thu lai !"
echo "-------------------------------------------------------------------------"
read -p "Nhan [Enter] de tiep tuc ..."
clear
bash /etc/vpssim/.tmp/vpssim-setup
exit
fi  

checkpass="^[a-zA-Z0-9_][-a-zA-Z0-9_]{0,61}[a-zA-Z0-9_]$";
if [[ ! "$passrootmysql" =~ $checkpass ]]; then
clear
echo "========================================================================="
echo "Ban chi duoc dung chu cai va so de dat mat khau MySQL !"
echo "-------------------------------------------------------------------------"
echo "Ban vui long thu lai !"
echo "-------------------------------------------------------------------------"
read -p "Nhan [Enter] de tiep tuc ..."
clear
bash /etc/vpssim/.tmp/vpssim-setup
exit
fi  

prompt="Nhap lua chon cua ban: "
options=( "MariaDB 10.3 " "MariaDB 10.2 " "MariaDB 10.1" "MariaDB 10.0")
echo "=========================================================================="
echo "Lua Chon Cai Dat Phien Ban MariaDB  "
echo "=========================================================================="
PS3="$prompt"
select opt in "${options[@]}"; do 

    case "$REPLY" in
    1) mariadbversion="10.3"; break;;
    2) mariadbversion="10.2"; break;;
    3) mariadbversion="10.1"; break;;
    4) mariadbversion="10.0"; break;;
            
    *) echo "Ban nhap sai ! Ban vui long chon so trong danh sach";continue;;
    esac  
done
if [ "$mariadbversion" = "10.0" ]; then
phienbanmariadb=10.0
elif [ "$mariadbversion" = "10.1" ]; then
phienbanmariadb=10.1
elif [ "$mariadbversion" = "10.2" ]; then
phienbanmariadb=10.2
else
phienbanmariadb=10.3
fi
arch=`uname -m`
if [ "$(rpm -qf --queryformat="%{VERSION}" /etc/redhat-release)" == "6" ]; then 
centosver=6
else
centosver=7
fi
if [ "$arch" = "x86_64" ]; then
XXX=amd64
else
XXX=x86
fi
# Download vpssim_main_menu + Chmod
cd /etc/vpssim
download_vpssim_data () {
rm -rf menu.zip
wget --progress=dot https://vpssim.vn/script/vpssim/menu.zip 2>&1 | grep --line-buffered "%"
unzip -q menu.zip
rm -rf menu.zip
}
download_vpssim_data
if [ ! -f /etc/vpssim/menu/inc/check-download-menu ]; then
download_vpssim_data
fi
cd
find /etc/vpssim/menu/inc -type f -exec chmod 755 {} \;
/etc/vpssim/menu/inc/vpssim-cai-dat-glibc-khong-duoc-ma-hoa  # Setup GLIBC 2.17 (Centos 6) or GLIBC 2.22 (centos 7)
/etc/vpssim/menu/inc/set-permison-vpssim-menu
/etc/vpssim/menu/inc/download-vpssim-main-menu
###############################################################################
#Download Nginx, VPSSIM & phpMyadmin Version
/etc/vpssim/menu/inc/vpssim-download-nginx-version-phpmyadmin-version-vpssim-version
###############################################################################
phpmyadmin_version=`cat /etc/vpssim/.tmp/version.vpssim | awk '{print $1}'`
Nginx_VERSION=`cat /etc/vpssim/.tmp/version.vpssim | awk '{print $2}'`
vpssim_version=`cat /etc/vpssim/.tmp/version.vpssim | awk '{print $3}'`


