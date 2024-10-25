#!/bin/bash

# Memuat informasi yang diperlukan
NS=$(cat /etc/xray/dns)
PUB=$(cat /etc/slowdns/server.pub)
domain=$(cat /etc/xray/domain)

# Definisi warna
grenbo="\e[92;1m"
NC='\e[0m'

# Pindah ke direktori systemd untuk membersihkan layanan sebelumnya
cd /etc/systemd/system/
rm -rf kyt.service
cd

# Instalasi paket yang diperlukan
cd /usr/bin
rm -rf kyt
rm -rf bot
apt update && apt upgrade -y
apt install python3 python3-pip git -y

# Unduh dan siapkan bot
cd /usr/bin
wget https://raw.githubusercontent.com/ryankputra/xnew/main/Bot/bot.zip
unzip bot.zip
mv bot/* /usr/bin
chmod +x /usr/bin/*
rm -rf bot.zip

# Unduh dan siapkan kyt
clear
cd
wget https://raw.githubusercontent.com/ryankputra/xnew/main/Bot/kyt.zip
unzip kyt.zip
cp -r kyt /usr/bin/
cd /usr/bin
pip3 install -r kyt/requirements.txt

# Unduh dan siapkan skrip 2fa.py
wget https://raw.githubusercontent.com/ryankputra/xnew/main/Bot/2fa.py -O /usr/bin/2fa.py
chmod +x /usr/bin/2fa.py

# Minta pengguna untuk memasukkan Token Bot dan ID Admin
echo ""
figlet  RyyStore.V2 Vpn  | lolcat
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " \e[1;97;101m          TAMBAH PANEL BOT          \e[0m"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "${grenbo}Tutorial Membuat Bot dan ID Telegram${NC}"
echo -e "${grenbo}[*] Buat Bot dan Token Bot : @BotFather${NC}"
echo -e "${grenbo}[*] Info ID Telegram : @MissRose_bot, perintah /info${NC}"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Membaca input pengguna untuk Token Bot dan ID Admin
read -e -p "[*] Masukkan Token Bot Anda : " bottoken
read -e -p "[*] Masukkan ID Telegram Anda :" admin

# Simpan detail bot dan admin ke var.txt
echo -e BOT_TOKEN='"'$bottoken'"' >> /usr/bin/kyt/var.txt
echo -e ADMIN='"'$admin'"' >> /usr/bin/kyt/var.txt
echo -e DOMAIN='"'$domain'"' >> /usr/bin/kyt/var.txt
echo -e PUB='"'$PUB'"' >> /usr/bin/kyt/var.txt
echo -e HOST='"'$NS'"' >> /usr/bin/kyt/var.txt

# Bersihkan database sebelumnya
rm /etc/bot/.bot.db
echo "#bot# ${bottoken} ${admin}" >> /etc/bot/.bot.db
clear

# Buat layanan systemd untuk kyt
cat > /etc/systemd/system/kyt.service << END
[Unit]
Description=Simple kyt - @kyt
After=network.target

[Service]
WorkingDirectory=/usr/bin
ExecStart=/usr/bin/python3 -m kyt
Restart=always

[Install]
WantedBy=multi-user.target
END

# Mulai dan aktifkan layanan
systemctl start kyt 
systemctl enable kyt
systemctl restart kyt
cd /root
rm -rf kyt*

# Pesan penyelesaian
clear
echo "Selesai"
echo "Data Bot Anda"
echo -e "==============================="
echo "Token Bot         : $bottoken"
echo "Admin             : $admin"
echo "Domain            : $domain"
echo -e "==============================="
echo "Pengaturan selesai"
echo "Instalasi lengkap, ketik /menu di bot Anda"
echo " "
read -p "Tekan sembarang tombol untuk keluar"
menu
