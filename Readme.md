# Kobo Toolchain Docker

Some docker files to setup and run a debian bookworm docker with Qt 5.15 compiled for kobo devices along with a bunch of libs. As per [kobo-qt-setup-scripts](https://github.com/Aryetis/kobo-qt-setup-scripts). Because koxtoolchain can be a bit finnicky with gcc-15 at the moment.

## How to use

1. Install docker using your favorite package manager
2. Clone this repository `git clone https://github.com/Aryetis/kobo-qt-setup-scripts.git`
3. Share your UID and GID with your future docker's user  `echo "UID=$(id -u)" >> .env && echo "GID=$(id -g)" >> .env`
4. Build the docker image `docker-compose build` (**IT WILL TAKE A WHILE**, like in between half an hour and two depending of your config)
5. Start the docker image in the background `docker-compose up -d`
6. Connect to your docker image `ssh kobodev@172.20.0.2 -p 2345` through ssh and compile your code using `arm-kobo-linux-gnueabihf-g++`
7. But you'll probably want to configure your IDE (I'm using QtCreator for that) to connect to your docker image through ssh instead.
8. You probably gonna need to get the qt-bin files from the docker, to do so run `docker cp <containerID>:/home/kobodev/qt-bin /home/hostname/qt-bin/` (check container ID with `docker ps`)
9. Stop that container when you're done with it `docker compose down`

## Wait but I know nothing about docker !

Me neither ! RTFM for stuff such as lazydocker, ask google or your prefered local AI, etc... 

Keep in mind that your IDE (eg : Qtcreator) is likely gonna run its own instance of your docker image. So the instance you'll up manually won't be the same as your IDE's.

In the meantime and for future me. Here's a bunch of useful commands for it in rapid fire.

- `docker-compose build --no-cache`, rebuild docker's image from scratch
- `docker-compose exec kobodevcontainer bash`, start and attach a bash to your docker's image
- `docker-compose exec -u root kobodevcontainer bash`, same but start it as root
