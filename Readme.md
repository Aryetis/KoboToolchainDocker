# Kobo Toolchain Docker

Some docker files to setup and run a debian bookworm docker with Qt 5.15 compiled for kobo devices along with a bunch of libs. As per [kobo-qt-setup-scripts](https://github.com/Aryetis/kobo-qt-setup-scripts). Because koxtoolchain can be a bit finnicky with gcc-15 at the moment.

## How to use

1. Install docker using your favorite package manager
2. Clone this repository `git clone https://github.com/Aryetis/kobo-qt-setup-scripts.git`
3. Share your UID and GID with your future docker's user  `echo "UID=$(id -u)" >> .env && echo "GID=$(id -g)" >> .env`
4. Build the docker image `docker-compose build`, **IT WILL TAKE A WHILE**, like in between half an hour and two depending of your config. And docker is likely to complain about the log being too long. 
   If it fails during the `./install_toolchain.sh` step, try again later on. The servers hosting the toolchain can be flimsy sometimes.

From now on you have a functional docker image, containing the necessary toolchain, compiler, libraries, qt binaries and libs

5. Start an instance of the docker image in the background `docker-compose up -d`
6. Let's extract the necessary qt binaries and extra libraries from our docker's instance. We will have to deploy them to our Kobo's /mnt/onboard/.adds/ folder.
   To do that, first note your docker's instance id, it should be displayed when running `sudo docker ps`
   and then you can run `cp <containerId>:/home/kobodev/Workspace/kobo-qt-setup-scripts/deploy/ ./deploy/`
   Or in one line (assuming you didn't run any other docker instance in between those steps) `docker cp $(docker ps -alq):/home/kobodev/Workspace/kobo-qt-setup-scripts/deploy/ ./deploy/`

To tidy things up

7. You can if you want connect to your docker image `ssh kobodev@172.20.0.2 -p 2345` through ssh and compile  code using `arm-kobo-linux-gnueabihf-g++`
8. But you'll probably want to configure your IDE (I'm using QtCreator for that) to use your Docker's image (not instance) instead. Its name should be "kobotoolchaindocker-kobodevcontainer".
9. Stop that docker's instance when you're done with it by running `docker compose down`

## Wait but I know nothing about docker !

Me neither ! RTFM for stuff such as lazydocker, ask google or your prefered local AI, etc... 

Keep in mind that your IDE (eg : Qtcreator) is likely gonna run its own instance of your docker image. So the instance you'll up manually won't be the same as your IDE's. You are using Docker! The image is setup by running `docker-compose build` and then you or your IDE can create multiple instances of it. Each instances will have its own filesystem and differ from the created base Image.

Note the presence of the .env file to pass your host's user UID and GID if you ever want to setup volume.

In the meantime and for future me. Here's a bunch of useful commands for it in rapid fire.

- `docker-compose build --no-cache`, rebuild docker's image from scratch
- `docker-compose exec kobodevcontainer bash`, start and attach a bash to your docker's image
- `docker-compose exec -u root kobodevcontainer bash`, same but start it as root
