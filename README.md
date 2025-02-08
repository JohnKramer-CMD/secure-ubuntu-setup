# Secure Ubuntu Setup

Этот репозиторий содержит скрипты для **автоматической настройки безопасности** на **Ubuntu Server **. 
Скрипты настраивают сервер для безопасной работы, обновляют систему и делают её готовой для использования в продакшн-среде.

## Скрипт: `secure-ubuntu-setup.sh`

### Описание
Скрипт **`secure-ubuntu-setup.sh`** выполняет следующие задачи на сервере Ubuntu:

1. **Обновление системы**: обновляет все пакеты до последних стабильных версий.
2. **Настройка SSH**:  
   - Меняет стандартный порт SSH.
   - Отключает возможность входа под root.
   - Запрещает использование пустых паролей.
3. **Создание нового пользователя**:  
   - Если указан новый пользователь, он будет создан.
   - Дается права sudo новому пользователю.
4. **Проверка пользователей**:  
   - Проверяет существующих пользователей и удаляет их, если они не нужны.
   - Убирает права sudo у несанкционированных пользователей.
5. **Настройка брандмауэра (UFW)**:  
   - Открывает только необходимые порты, например, 22 (SSH) и 80 (HTTP).
6. **Резервное копирование**:  
   - Создаёт резервную копию текущей конфигурации системы (снапшот tar).
7. **Автоматические обновления безопасности**:  
   - Настроены автоматические обновления для поддержания безопасности сервера.

### Как использовать

1. Клонируйте репозиторий на ваш сервер:
   ```bash
   git clone https://github.com/JohnKramer-CMD/My_Linux_scripts.git
   cd My_Linux_scripts
2. Дайте права на выполнение скрипту:
   ```bash
   chmod +x secure-ubuntu-setup.sh
3. Запустите скрипт:
    ```bash
    sudo ./secure-ubuntu-setup.sh

###Скрипт попросит у вас пароль для выполнения привилегированных команд. После его выполнения сервер будет готов к безопасному использованию.

Примечания

  - Скрипт рекомендуется использовать на чистой установке Ubuntu 24.04.1.
  - Для изменения настроек скрипта или добавления новых функций, отредактируйте файл secure-ubuntu-setup.sh и создайте новый коммит.
