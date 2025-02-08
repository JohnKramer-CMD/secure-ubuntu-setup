#!/bin/bash

set -e  # Остановка при ошибке

# 🛠 Обновление системы
echo "[1] Обновление системы..."
sudo apt update && sudo apt upgrade -y

# 👤 Создание пользователя
USERNAME="admin"
echo "[2] Создаём пользователя $USERNAME..."
if id "$USERNAME" &>/dev/null; then
    echo "⚠️ Пользователь $USERNAME уже существует, пропускаем."
else
    sudo adduser --disabled-password --gecos "" $USERNAME
    echo "$USERNAME:admin" | sudo chpasswd  # ⚠️ Поменяйте пароль после установки!
    sudo usermod -aG sudo $USERNAME
fi

# 🔍 Проверка всех пользователей в системе
echo "[3] Проверяем лишних пользователей..."
EXCEPTIONS=("root" "$USERNAME")  # Кого НЕ трогаем
for user in $(awk -F: '{if ($3 >= 1000) print $1}' /etc/passwd); do
    if [[ ! " ${EXCEPTIONS[@]} " =~ " ${user} " ]]; then
        echo "❌ Удаляем пользователя: $user"
        sudo deluser --remove-home "$user"
    fi
done

# 🛑 Убираем права sudo у всех, кроме $USERNAME
echo "[4] Убираем лишние sudo-доступы..."
for sudo_user in $(getent group sudo | cut -d: -f4 | tr ',' ' '); do
    if [[ "$sudo_user" != "$USERNAME" ]]; then
        echo "🚫 Забираем sudo у: $sudo_user"
        sudo deluser "$sudo_user" sudo
    fi
done

# 🔐 Настройка SSH
echo "[5] Настройка SSH..."
sudo sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# 🛡 Настройка UFW (брандмауэр)
echo "[6] Настройка UFW..."
sudo apt install ufw -y
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status

# 🏴‍☠️ Установка Fail2Ban (защита от брутфорса)
echo "[7] Установка Fail2Ban..."
sudo apt install fail2ban -y
sudo systemctl enable fail2ban --now

# 📊 Установка инструментов мониторинга
echo "[8] Установка htop и net-tools..."
sudo apt install htop net-tools -y

# 🔄 Автоматическое обновление
echo "[9] Настройка автоматических обновлений..."
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades

# 💾 Настройка резервного копирования BorgBackup
BACKUP_DIR="/backup/borg"
echo "[10] Установка BorgBackup и настройка бэкапов..."
sudo apt install borgbackup -y
sudo mkdir -p $BACKUP_DIR
sudo borg init -e none $BACKUP_DIR

# 🏗 Запуск первого бэкапа
echo "[11] Запуск первого бэкапа..."
borg create --stats $BACKUP_DIR::backup-$(date +%F) /etc /home /var

echo "✅ Настройка завершена!"
