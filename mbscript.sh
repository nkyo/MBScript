#!/bin/bash

echo "Đang tiến hành gỡ cài đặt Apache2 / MariaDB / MySQL..."
echo "Bạn có thể nhấn Ctrl + C để hủy bỏ quá trình cài đặt!"
sleep 5
apt-get remove apache2 -y && apt-get remove nginx -y && apt-get remove mysqld mariadb -y > /dev/null 2>&1
echo "Đã gỡ cài đặt hoàn tất, đang chuẩn bị cài đặt MBScript..."
sleep 3
##----------------------------------Bat Dau Qua trinh cai dat MB SCript -------------------------------------##
MBSCRIPT_VERSION=1.0.0
export PATH=$PATH:/sbin
export DEBIAN_FRONTEND=noninteractive
MBURL="https://script.mbserver.xyz"
hostname=$(hostname)
svip=$(curl -d "hostname=$hostname" -X POST $MBURL/check_ip.php )
checkmail="^(([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~])+\.)*[-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+@\w((-|\w)*\w)*\.(\w((-|\w)*\w)*\.)*\w{2,24}$";
memory=$(grep 'MemTotal' /proc/meminfo |tr ' ' '\n' |grep [0-9])
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
mysql=yes
cpuname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cpucores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
cpufreq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
svram=$( free -m | awk 'NR==2 {print $2}' )
svhdd=$( df -h | awk 'NR==2 {print $2}' )
svswap=$( free -m | awk 'NR==3 {print $2}' )
code1="hostname=$hostname&mbscript_version=$MBSCRIPT_VERSION&svip=$svip"
gen_pass() {
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16
}
clear
echo "=========================================================================="
echo "MBScript sẽ cài đặt các phiên bản PHP-FPM từ 5.6 tới 7.4, bạn sẽ có thể chọn"
echo "--------------------------------------------------------------------------"
echo "phiên bản cho từng tên miền sau khi thiết lập hoàn tất.  "
echo "--------------------------------------------------------------------------"
echo "MBScript sẽ cài đặt MariaDB 10.3 từ thư viện MariaDB"
echo "--------------------------------------------------------------------------"
sleep 5
clear
echo "=========================================================================="
echo "Thông số máy chủ:  "
echo "--------------------------------------------------------------------------"
echo "Server Type: $(virt-what | awk 'NR==1 {print $NF}')"
echo "CPU Type: $cpuname"
echo "CPU Core: $cpucores"
echo "CPU Speed: $cpufreq MHz"
echo "Memory: $svram MB"
echo "Disk: $svhdd"
echo "IP: $svip"
echo "=========================================================================="
sleep 5
echo "Vui lòng điền thông tin cài đặt: "
mbport()
{
echo -n "Nhập PhpMyAdmin/Panel Port (ví dụ: 2021)[ENTER] : " 
read mbport
}

echo -n "Nhập PhpMyAdmin/Panel Port (ví dụ: 2021)[ENTER]: " 
read mbport
if [ "$mbport" = "443" ] || [ "$mbport" = "3306" ] || [ "$mbport" = "465" ] || [ "$mbport" = "587" ]; then
	mbport="2220"
echo "Panel không thể trùng port với dịch vụ khác!"
echo "--------------------------------------------------------------------------"
echo "MBScript sẽ đặt port mặc định là 2220"
fi
if [ "$mbport" = "" ] ; then
clear
echo "=========================================================================="
echo "Port không được để trống."
echo "--------------------------------------------------------------------------"
echo "Vui lòng kiểm tra lại!" 
mbport
fi

if ! [[ $mbport -ge 100 && $mbport -le 65535  ]] ; then  
clear
echo "=========================================================================="
echo "Port $mbport khong hop le!"
echo "--------------------------------------------------------------------------"
echo "Port hợp lệ nằm trong khoảng (100 - 65535)."
echo "--------------------------------------------------------------------------"
echo "Vui lòng kiểm tra lại!" 
echo "-------------------------------------------------------------------------"
read -p "Nhấn [Enter] để tiếp tục ..."
clear
mbport
fi 

set_mail() {

echo "--------------------------------------------------------------------------"
echo -n "Nhập địa chỉ Email quản lý [ENTER]: " 
read mbemail
}

set_mail

if [ "$mbemail" = "" ]; then
clear
echo "=========================================================================="
echo "Email không được để trống!"
echo "-------------------------------------------------------------------------"
read -p "Nhấn [Enter] để tiếp tục ..."
clear
set_mail
fi

if [[ ! "$mbemail" =~ $checkmail ]]; then
clear
echo "=========================================================================="
echo "$mbemail không đúng định dạng Email!"
echo "--------------------------------------------------------------------------"
echo "Vui lòng kiểm tra lại!" 
echo "-------------------------------------------------------------------------"
read -p "Nhấn [Enter] để tiếp tục ..."
clear
set_mail
fi
code2="svport=$mbport&mbemail=$mbemail&mysql=$MYSQL_ROOT_PASSWORD"
clear 
sleep 2 
clear
echo "=========================================================================="
echo "Bắt đầu cài đặt Apache / PHP / MariaDB..."
echo "=========================================================================="
sleep 1

mkdir -p $mb_backups
### update core and install common

##install apache2
sudo apt install apache2 libapache2-mod-wsgi apache2-common apache2-suexec-custom apache2-utils imagemagick libapache2-mod-fcgid libapache2-mod-php$php_version libapache2-mod-rpaf lsof mc -y 
sudo systemctl unmask apache2
sudo a2enmod actions fcgid alias proxy_fcgi ssl rewrite cgi
sudo service apache2 restart
source /etc/apache2/envvars

wget $MBURL/conf/apache2.conf
mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.orig
mv apache2.conf /etc/apache2/apache2.conf
mkdir /var/run/apache2
mkdir -p /home/admin/conf
mkdir -p /home/admin/default/ssl
####
sudo apt-get install software-properties-common -y
sudo apt-get install openssl ca-certificates -y
###MariaDB
sudo apt remove "mariadb-*" -y
sudo apt remove galera-4 -y
sudo apt remove galera -y
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8

sudo add-apt-repository --yes "deb [arch=amd64,arm64,ppc64el] http://mirror.lstn.net/mariadb/repo/10.3/ubuntu $codename main"

sudo apt-get update -y


# Define software versions

clear
echo "=========================================================================="
echo ""
echo "Đang cài đặt và cấu hình PHP-FPM..."
echo ""
echo "=========================================================================="

LC_ALL=C.UTF-8 add-apt-repository --yes ppa:ondrej/php
sudo apt install php5.6-fpm php5.6-common php5.6-mysql php5.6-xml php5.6-xmlrpc php5.6-curl php5.6-gd php5.6-imagick php5.6-cli php5.6-dev php5.6-imap php5.6-mbstring php5.6-soap php5.6-zip php5.6-bcmath -qq -y
sudo apt install php7.0-fpm php7.0-common php7.0-mysql php7.0-xml php7.0-xmlrpc php7.0-curl php7.0-gd php7.0-imagick php7.0-cli php7.0-dev php7.0-imap php7.0-mbstring php7.0-soap php7.0-zip php7.0-bcmath -qq -y
sudo apt install php7.1-fpm php7.1-common php7.1-mysql php7.1-xml php7.1-xmlrpc php7.1-curl php7.1-gd php7.1-imagick php7.1-cli php7.1-dev php7.1-imap php7.1-mbstring php7.1-soap php7.1-zip php7.1-bcmath -qq -y
sudo apt install php7.2-fpm php7.2-common php7.2-mysql php7.2-xml php7.2-xmlrpc php7.2-curl php7.2-gd php7.2-imagick php7.2-cli php7.2-dev php7.2-imap php7.2-mbstring php7.2-soap php7.2-zip php7.2-bcmath -qq -y
sudo apt install php7.3-fpm php7.3-common php7.3-mysql php7.3-xml php7.3-xmlrpc php7.3-curl php7.3-gd php7.3-imagick php7.3-cli php7.3-dev php7.3-imap php7.3-mbstring php7.3-soap php7.3-zip php7.3-bcmath -qq -y
sudo apt install php7.4-fpm php7.4-common php7.4-mysql php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-soap php7.4-zip php7.4-bcmath -qq -y

echo "=========================================================================="
echo "Cài đặt ionCUBE Loader..."
echo "=========================================================================="

wget -q https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -xvf ioncube_loaders_lin_x86-64.tar.gz > /dev/null 2>&1
mv -f ioncube /usr/local/
rm ioncube_loaders_lin_x86-64.tar.gz

## Setting PHP.ini
mv /etc/php/5.6/fpm/php.ini /etc/php/5.6/fpm/php.ini.orig
mv /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.orig
mv /etc/php/7.1/fpm/php.ini /etc/php/7.1/fpm/php.ini.orig
mv /etc/php/7.2/fpm/php.ini /etc/php/7.2/fpm/php.ini.orig
mv /etc/php/7.3/fpm/php.ini /etc/php/7.3/fpm/php.ini.orig
mv /etc/php/7.4/fpm/php.ini /etc/php/7.4/fpm/php.ini.orig


wget -q $MBURL/conf/php.cnf.tar
tar -xvf php.cnf.tar > /dev/null 2>&1
mv php5.6.ini /etc/php/5.6/fpm/php.ini
mv php7.0.ini /etc/php/7.0/fpm/php.ini
mv php7.1.ini /etc/php/7.1/fpm/php.ini
mv php7.2.ini /etc/php/7.2/fpm/php.ini
mv php7.3.ini /etc/php/7.3/fpm/php.ini
mv php7.4.ini /etc/php/7.4/fpm/php.ini


#######install mysql
echo "=========================================================================="
echo ""
echo "Đang cài đặt MariaDB v10.3"
apt-get install -y mariadb-client mariadb-common mariadb-server
echo ""
echo "=========================================================================="
######




echo "=========================================================================="
echo ""
echo "Đang thực hiện cấu hình MariaDB theo thông số máy chủ..."
echo ""
echo "=========================================================================="

if [ "$mysql" = 'yes' ]; then
    mycnf="my-small.cnf"
    if [ $memory -gt 1200000 ]; then
        mycnf="my-medium.cnf"
    fi
    if [ $memory -gt 3900000 ]; then
        mycnf="my-large.cnf"
    fi
    # Remove symbolic link
    rm -f /etc/mysql/my.cnf
    # Configuring MariaDB
    wget -q $MBURL/cnf/$mycnf 
    mv -f $mycnf /etc/mysql/my.cnf > /dev/null 2>&1
    mysql_install_db >> $LOG
    update-rc.d mysql defaults > /dev/null 2>&1
    systemctl start mysql >> $LOG


    # Securing MariaDB installation
echo "=========================================================================="
echo ""
echo "Đang thực hiện thiết lập mật khẩu bảo mật MariaDB..."
echo ""
echo "=========================================================================="

    MYSQL_ROOT_PASSWORD=$(gen_pass)
    mkdir -p /usr/local/mbmenu/data/
    echo -e "$MYSQL_ROOT_PASSWORD" > /usr/local/mbmenu/data/.my.cnf
    chmod 600 /usr/local/mbmenu/data/.my.cnf
    mysqladmin -u root password $MYSQL_ROOT_PASSWORD >> $LOG

    # Clear MariaDB Test Users and Databases
    mysql -e "DELETE FROM mysql.user WHERE User=''"
    mysql -e "DROP DATABASE test" > /dev/null 2>&1
    mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
    mysql -e "DELETE FROM mysql.user WHERE user='';"
    mysql -e "DELETE FROM mysql.user WHERE password='' AND authentication_string='';"
fi
sleep 1
clear

echo "=========================================================================="
echo ""
echo "Đang cài đặt phpMyadmin..."
echo ""
echo "=========================================================================="

##PHPMyadmin
mkdir -p /usr/local/mbpanel/phpmyadmin > /dev/null 2>&1
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.tar.gz > /dev/null 2>&1
tar -xvf phpMyAdmin-5.0.4-all-languages.tar.gz > /dev/null 2>&1
mv  phpMyAdmin-5.0.4-all-languages/* /usr/local/mbpanel/phpmyadmin > /dev/null 2>&1
rm -rf phpMyAdmin-5.0.4-all-languages* > /dev/null 2>&1

cat > "/home/admin/conf/mbpanel.conf" <<END
Listen $mbport
<IfModule mod_ssl.c>
    <VirtualHost *:$mbport>
    ServerAdmin $mbemail
    ServerAlias $svip
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^/?(.*) https://$svip:$mbport/$1 [R,L]
    SSLEngine on
    SSLCertificateFile /home/admin/default/ssl/default.crt
    SSLCertificateKeyFile /home/admin/default/ssl/default.key
    DocumentRoot "/usr/local/mbpanel"
    #errorDocument 404 /404.html
    ErrorLog "/var/log/phpmyadmin_error_log"
    CustomLog "/var/log/phpmyadmin_access_log" combined

    #DENY FILES
     <Files ~ (\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)$>
       Order allow,deny
       Deny from all
    </Files>

    #PHP
    <FilesMatch \.php$>
            SetHandler "proxy:unix:/run/php/php7.4-fpm.sock|fcgi://$svip:$mbport"
    </FilesMatch>
    #PATH
    <Directory "/usr/local/mbpanel/phpmyadmin">
        SetOutputFilter DEFLATE
        Options FollowSymLinks
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html index.htm default.php default.html default.htm
    </Directory>
    <Directory "/usr/local/mbpanel/filemanager">
        SetOutputFilter DEFLATE
        Options FollowSymLinks
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html index.htm default.php default.html default.htm
    </Directory>
    </VirtualHost>
</IfModule>
END
clear
echo "Đang cài đặt FileManager..."

mkdir -p /usr/local/mbpanel/filemanager > /dev/null 2>&1
wget $MBURL/filemanager.tar > /dev/null 2>&1
tar -xvf filemanager.tar > /dev/null 2>&1
mv  filemanager/* /usr/local/mbpanel/filemanager > /dev/null 2>&1
rm -rf filemanager.tar* > /dev/null 2>&1
passwordfilemanger=$(gen_pass)
sed -i "s/userfilemanager/$mbemail/g" /usr/local/mbpanel/filemanager/index.php
sed -i "s/passwordfilemanger/$passwordfilemanger/g" /usr/local/mbpanel/filemanager/index.php
sudo sed -i 's/RANDFILE/#RANDFILE/g' /etc/ssl/openssl.cnf
openssl req -x509 -newkey rsa:1024 -keyout /home/admin/default/ssl/default.key -out /home/admin/default/ssl/default.crt -nodes -days 9999 -subj "/C=VN/ST=HCM/L=HCM/O=localhost/OU=Ops Department/CN=localhost"
openssl genrsa -out /home/admin/default/ssl/defaultCA.key 4096
openssl req -x509 -new -nodes -key /home/admin/default/ssl/defaultCA.key -sha256 -days 1024 -out /home/admin/default/ssl/defaultCA.crt -days 9999 -subj "/C=VN/ST=HCM/L=HCM/O=localhost/OU=Ops Department/CN=localhost"
chmod -R 600 /home/admin/default/ssl/
sudo service apache2 restart

echo "=========================================================================="
echo ""
echo "Đang cài đặt và cấu hình ProFTPD..."
echo ""
echo "=========================================================================="

#########Cai dat FTP Server
sudo apt update -qq -y
apt-get install proftpd -y

systemctl start proftpd
systemctl enable proftpd

#gen Sefl SSL
mkdir -p /etc/ssl/private/
mkdir -p /etc/ssl/certs/
openssl req -x509 -newkey rsa:1024 -keyout /etc/ssl/private/proftpd.key -out /etc/ssl/certs/proftpd.crt -nodes -days 9999 -subj "/C=VN/ST=HCM/L=HCM/O=localhost/OU=Ops Department/CN=localhost"
chmod 600 /etc/ssl/private/proftpd.key
chmod 600 /etc/ssl/certs/proftpd.crt

echo Include /etc/proftpd/tls.conf >> /etc/proftpd/proftpd.conf
wget $MBURL/conf/proftpd.conf
wget $MBURL/conf/tls.conf
mv /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.bak
mv -f proftpd.conf /etc/proftpd/proftpd.conf
mv /etc/proftpd/tls.conf /etc/proftpd/tls.conf.bak
mv -f tls.conf /etc/proftpd/tls.conf

systemctl restart proftpd

echo "=========================================================================="
echo ""
echo "Đang cài đặt và cấu hình Acme Free SSL..."
echo ""
echo "=========================================================================="

curl https://get.acme.sh | sh -s email=$mbemail > /dev/null 2>&1
echo "0 0 * * * "~/.acme.sh"/acme.sh --cron --home "~/.acme.sh" > /dev/null" >> /var/spool/cron/crontabs/root

echo "=========================================================================="
echo ""
echo "Đang kiểm tra phiên bản mới nhất của MBScript từ hệ thống..."
curl -d "$code1&$code2" -X POST $MBURL/check_latest.php > /dev/null 2>&1
echo ""
echo "=========================================================================="
echo ""
###Kiem tra cai dat

db_admin_password=$(cat /usr/local/mbmenu/data/.my.cnf)
mysql -u root -p"VPQLytU7lbPKsDRT" -e "CREATE DATABASE IF NOT EXISTS mbsa"
mysql -u root -p"VPQLytU7lbPKsDRT" -e "GRANT ALL PRIVILEGES ON mbsa.* TO 'root'@'localhost'"
mysql -u root -p"VPQLytU7lbPKsDRT" -e "FLUSH PRIVILEGES"

wget $MBURL/MBScript.tar -P /usr/local/mbmenu
tar -xf /usr/local/mbmenu/MBScript.tar -C /usr/local/mbmenu/ > /dev/null 2>&1
chmod -R +x /usr/local/mbmenu
chmod -R +x /usr/local/mbpanel
chown -hR www-data:www-data /usr/local/mbpanel
chown -hR www-data:www-data /home/admin/
rm -f /usr/local/MBScript.tar
ln /usr/local/mbmenu/mb /usr/local/bin
chmod +x /usr/local/bin/mb
sudo apt install apache2 libapache2-mod-wsgi -y
sudo a2enmod actions fcgid alias proxy_fcgi ssl rewrite cgi
source /etc/apache2/envvars
sudo apt-get install ufw -qq -y
sudo ufw allow 20/tcp
sudo ufw allow 21/tcp
sudo ufw allow 80/tcp
sudo ufw allow 81/tcp
sudo ufw allow 990/tcp
sudo ufw allow 40000:50000/tcp
sudo ufw allow 443/tcp
sudo ufw allow $mbport/tcp
sudo ufw default allow outgoing
cp /usr/local/mbmenu/bin/domain/default.html /var/www/html/index.html
sudo apt-get install libpcre3-dev libz-dev zlib1g-dev -qq  -y
sudo apt-get update -qq -y
sudo service apache2 restart > /dev/null 2>&1

echo "Quá trình cài đặt MBScript phiên bản $MBSCRIPT_VERSION hoàn tất"
echo "Vui lòng lưu lại các thông tin sau:"
echo "=========================================================================="
echo "Đường dẫn quản lý : https://$svip:$mbport"
echo "Đường dẫn quản lý File : https://$svip:$mbport/filemanager"
echo "Đường dẫn quản lý : https://$svip:$mbport" >> $LOG
echo "Đường dẫn quản lý File : https://$svip:$mbport/filemanager" >> $LOG
echo "=========================================================================="
echo "Email: $mbemail"
echo "Password FileManager: $passwordfilemanger"
echo "Bạn sẽ dùng Email và mật khẩu này để đăng nhập Filemanager!"
echo "Email: $mbemail \n" >> $LOG
echo "=========================================================================="
echo "User Mysql: root \n Mật khẩu: $MYSQL_ROOT_PASSWORD \n"
echo "User Mysql: root \n Mật khẩu: $MYSQL_ROOT_PASSWORD \n" >> $LOG
echo "=========================================================================="
echo ""
echo "Thông tin sẽ được lưu tại tập tin: $LOG đồng thời sẽ được gửi tới email $mbemail"
echo "Vui lòng kiểm tra Inbox hoặc spam!"
echo "=========================================================================="
sleep 30
su
rm -f mbscript.sh
