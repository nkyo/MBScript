
#!/bin/sh

rm -f mbscript.sh
OUTPUT=$(cat /etc/*release)
if  echo $OUTPUT | grep -q "Ubuntu" ; then
        echo "Dang tien hanh cap nhat cac thu vien Ubuntu va tai goi cai dat MBScript..."
#---- Bat dau chay lenh keo cai thu vien ve----#        
apt-get install curl wget cron -y 1 > /dev/null
curl --silent -o mbscript.sh "https://script.mbserver.xyz/mbscript" 2>/dev/null
chmod +x mbscript.sh
else

                echo -e "\nMBScript hien tai chi ho tro Ubuntu do he dieu hanh Centos se End Of Life som hon du kien.\n"
                echo -e "\nThong tin chi tiet: https://wiki.centos.org/About/Product\n"
                exit 1
fi
rm -f install.sh
sudo bash mbscript.sh
