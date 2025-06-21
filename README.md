# o-spot
Простой веб сервер в докере для отображения содержимой папки. В качестве хост машины предлагается успользовать Ubuntu 24.04. Подключение к ней рекомендуется использовать SSH.
## Подготовка
### Установка Docker

```bash
sudo apt-get update && sudo apt-get install && \
ca-certificates curl && \
sudo install -m 0755 -d /etc/apt/keyrings && \
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
sudo chmod a+r /etc/apt/keyrings/docker.asc && \
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update && \
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

или есть вариант короче (пробовал только на raspberry pi):

```bash
curl -fsSL https://get.docker.com | sudo sh
```

Добавить пользователя в группу, чтобы выолнять команды докера без sudo:

```bash
sudo usermod -aG docker $USER
```

перелогиниться, чтобы изменения применились (или `sudo reboot now`)
### Склонировать репозиторий
В любое место скопировать себе репозиторий и перейти в него:

```bash
git clone https://github.com/alpha-kudryash/o-spot.git && cd o-spot
```


### Настроить папку с результатами
Определиться с путём папки с результатами (пусть будет **/home/user/res/**). Сделать папку с результатами выполняемой

```bash
sudo chmod -R a+rX /home/user/res/
```

Для того, чтобы файлы в эту папку передавать, можно расшарить её по smb, можно передать по тому же SSH с помощью WinSCP на Windows (или использовать альтернативы на Linux, nautilus+sftp, FileZilla, gftp).

#### Расшарить папку SMB
Установить samba


```bash
sudo apt install samba
```

Задать пароль

```bash
sudo smbpasswd -a $USER
```

ввести пароль от smb, будет использоваться при подключении к папке.

Далее можно сделать правильно и вставить в конец файла:

```bash
sudo nano /etc/samba/smb.conf
```

Эти строки

```bash
[Results]
   path = /home/user/res/ # Вставить нужный путь
   valid users = $USER # Поменять на нужного пользователя
   read only = no
   browsable = yes
   writable = yes
   create mask = 0660
   directory mask = 0770
```

Но в таком случае Windows 10 не видит эту папку, поэтому я предлагаю просто заменить **/etc/samba/smb.conf** на ./etc/samba/smb.conf (из склонированного репозитория), сохранив исходный конфиг.

```bash
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp && sudo cp ./etc/samba/smb.conf /etc/samba/smb.conf
```

и поменять путь для папки и пользователя в файле:

```bash
sudo nano /etc/samba/smb.conf
```

Убедиться, что права корректные (поменять путь и пользователя)

```bash
chmod 770 /home/user/res/
chown $USER:$USER /home/user/res/
```

И перезапустить smb:

```bash
sudo systemctl restart smbd
```

### Запуск докер контейнера

Нужно, чтобы ничего не было запущено на 80 порту. В результате выполнения команды

```bash
sudo lsof -i :80
```

не должно быть ничего.
Сделать выполняемым скрипт **run_container.sh**:

```bash
chmod +x run_container.sh
```

Запустить скрипт
```bash
./run_container.sh
```

Запущенный докер использует папку **/home/user/res/**, в которую можно добавлять файлы и они сразу отобразятся на странице. Докер контейнер на будет запускаться при перезагрзке системы. Для ручного запуска контейнера (после разового запуска скрипты **run_container.sh**) нужно выполнить `docker start result-page`. Или обновить политику контейнера `docker update --restart unless-stopped result-page` для запуска при рестарте хост системы. В таком случае при ненадобности сервера нужно будет удалить этот контейнер (ниже будут команды) или снова поменять его политику запуска.

Для полного удаления докера образа и контейнера, нужно удалить контейнер, потом образ:

```bash
docker stop result-page && docker rm result-page && docker rmi host-result-page
```

### Проверка работы
После запуска докера на ip хостовой машины на порту 80 должен заработать веб страница с сожержимым папки. Находясь в сети хостовой машины нужно в браузере ввести ip адрес хостовой машины.

## Полезные команды докера
Для просмотра всех контейнеров

```bash
docker ps -a
```

Для удаления определённого контейнера (остановить и удалить)

```bash
docker stop <name or id> && docker rm <name or id>
```

Для просмотра всех образов

```bash
docker images
```

Для удаления определённого образа

```bash
docker rmi <name or id>
```