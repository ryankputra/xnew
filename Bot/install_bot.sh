#!/bin/bash

# Update dan install dependensi
sudo apt update
sudo apt install -y python3 python3-pip python3-venv

# Clone repository
git clone https://github.com/ryankputra/xnew.git

# Masuk ke direktori Bot
cd xnew/Bot

# Buat virtual environment
python3 -m venv botenv

# Aktifkan virtual environment
source botenv/bin/activate

# Install requirements
pip install -r requirements.txt

# Copy file 2fa.py
cp 2fa.py ~/xnew/Bot/

# Buat service systemd
sudo bash -c 'cat > /etc/systemd/system/telegram-bot.service << EOF
[Unit]
Description=Telegram 2FA Bot Service
After=network.target

[Service]
User=botuser
WorkingDirectory=/root/xnew/Bot
Environment="PATH=/root/xnew/Bot/botenv/bin"
ExecStart=/root/xnew/Bot/botenv/bin/python /root/xnew/Bot/2fa.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd dan mulai service
sudo systemctl daemon-reload
sudo systemctl enable telegram-bot.service
sudo systemctl start telegram-bot.service

echo "Instalasi selesai! Bot Telegram 2FA sudah berjalan."
