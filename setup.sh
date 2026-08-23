#!/bin/bash
echo "[$(date)] Memulai proses setup environment Web & Pterodactyl..."

export DEBIAN_FRONTEND=noninteractive

echo "[1/4] Memperbarui repositori dan menginstal utilitas dasar..."
apt-get update -y
apt-get install -y apt-transport-https ca-certificates software-properties-common curl wget git

echo "[2/4] Menyiapkan environment Node.js & PHP Stack..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs php-cli php-zip php-mysql php-bcmath php-mbstring php-xml composer

echo "[3/4] Menyiapkan Database MariaDB untuk Pterodactyl..."
apt-get install -y mariadb-server mariadb-client
systemctl enable mariadb
systemctl start mariadb

# Mengamankan dan membuat user database menggunakan kredensial dari YML
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SETUP_DB_PASS}';"
mysql -u root -p"${SETUP_DB_PASS}" -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p"${SETUP_DB_PASS}" -e "DROP DATABASE IF EXISTS test;"
mysql -u root -p"${SETUP_DB_PASS}" -e "FLUSH PRIVILEGES;"

echo "[4/4] Konfigurasi Docker & Persiapan Pterodactyl Wings..."
systemctl enable docker
systemctl start docker

# Mengunduh dependensi Pterodactyl Wings
mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64"
chmod u+x /usr/local/bin/wings

echo "=========================================================="
echo "[$(date)] SETUP SELESAI!"
echo "MySQL Root Password : ${SETUP_DB_PASS}"
echo "Wings Binary Path   : /usr/local/bin/wings"
echo "Untuk menghubungkan Wings, letakkan config.yml dari Panel ke /etc/pterodactyl/"
echo "Lalu jalankan via Telegram: /cmd sudo wings"
echo "=========================================================="
