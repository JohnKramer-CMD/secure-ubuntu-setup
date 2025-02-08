#!/bin/bash

# Проверка на выполнение с правами root
if [ "$(id -u)" -ne 0 ]; then
    echo "Этот скрипт должен быть запущен с правами root!" >&2
    exit 1
fi

# Обновление системы
echo "Обновление системы..."
apt update -y && apt upgrade -y
apt dist-upgrade -y

# Установка необходимых пакетов
echo "Установка необходимых пакетов..."
apt install -y ufw curl vim git

# Настройка SSH
echo "Настройка SSH..."
# Смена порта SSH (например, на 2222)
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
# Отключение входа root
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
# Запрещаем пустые пароли
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
# Перезапуск SSH
systemctl restart sshd

# Создание нового пользователя (если он не существует)
NEW_USER="admin"
if ! id "$NEW_USER" &>/dev/null; then
    echo "Создание нового пользователя $NEW_USER..."
    useradd -m -s /bin/bash "$NEW_USER"
    # Устанавливаем пароль для нового пользователя
    passwd "$NEW_USER"
    # Добавляем в группу sudo
    usermod -aG sudo "$NEW_USER"
    echo "Пользователь $NEW_USER создан и добавлен в группу sudo."
else
    echo "Пользователь $NEW_USER уже существует."
fi

# Удаление ненужных пользователей (если есть)
echo "Проверка ненужных пользователей..."
for user in $(awk -F: '{ print $1 }' /etc/passwd); do
    if [[ "$user" != "root" && "$user" != "$NEW_USER" ]]; then
        echo "Удаление пользователя $user..."
        deluser --remove-home "$user"
    fi
done

# Настройка брандмауэра UFW
echo "Настройка брандмауэра UFW..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 2222/tcp   # Порт SSH
ufw enable

# Настройка автоматических обновлений безопасности
echo "Настройка автоматических обновлений безопасности..."
apt install -y unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades

# Резервное копирование
echo "Создание резервной копии системы..."
tar -cvpzf /root/backup_$(date +%F).tar.gz --exclude=/proc --exclude=/tmp --exclude=/mnt --exclude=/sys /

# Завершающие действия
echo "Система настроена для безопасной работы!"
echo "Перезагрузите сервер для применения всех изменений."
