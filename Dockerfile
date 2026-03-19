# Dockerfile
FROM debian:bookworm

# Prevent interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Install libraries (and clean afterwards)
RUN apt-get update && apt-get install -y \
            build-essential autoconf automake bison flex \
            gawk libtool libtool-bin libncurses-dev curl file git \
            gperf help2man texinfo unzip wget cmake pkg-config python3 \
            mmv lftp clang libclang-dev llvm-dev rsync zip \
            openssh-server nano ragel \
            && apt-get clean && rm -rf /var/lib/apt/lists/*

# Setting passwordless user (using .env variables, mapped through docker-compose.yaml)
ARG UID=9999999 #invalid default value
ARG GID=9999999 #invalid default value
RUN groupadd -g ${GID} kobodev \
    && useradd -m -u ${UID} -g ${GID} -s /bin/bash kobodev \
    && passwd -d kobodev \
    && mkdir -p /home/kobodev/.ssh/ssh_host_keys \
    && chown -R kobodev:kobodev /home/kobodev

### now let's do non root stuff
ENV USER=kobodev
USER kobodev

#########################
#         sshd          #
#########################
# generate keys
RUN ssh-keygen -t ed25519 -f /home/kobodev/.ssh/ssh_host_keys/ssh_host_ed25519_key -N ''

# sshd_config file
RUN cat > /home/kobodev/sshd_config << EOF
Port 2345
PasswordAuthentication yes
PermitRootLogin no
PermitEmptyPasswords yes
UsePAM yes
HostKey ~/.ssh/ssh_host_keys/ssh_host_ed25519_key
PidFile /tmp/sshd.pid
AuthorizedKeysFile ~/.ssh/authorized_keys
EOF

#########################
# kobo-qt-setup-scripts #
#########################
RUN git clone --recurse-submodules https://github.com/Aryetis/kobo-qt-setup-scripts.git /home/kobodev/Workspace/kobo-qt-setup-scripts;
WORKDIR /home/kobodev/Workspace/kobo-qt-setup-scripts
RUN ./install_toolchain.sh > install_toolchain.log 2>&1
RUN ./get_qt.sh
RUN ./install_libs.sh
ENV PATH="$PATH:/home/kobodev/x-tools/arm-kobo-linux-gnueabihf/bin"
RUN ./build_qt.sh kobo config
RUN ./build_qt.sh kobo make
RUN ./build_qt.sh kobo install
RUN ./deploy_qt.sh
