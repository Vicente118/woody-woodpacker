FROM debian:bullseye-slim

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    gcc \
    g++ \
    gcc-multilib \
    g++-multilib \
    libc6-dev-i386 \
    binutils \
    make \
    nasm \
    vim \
    file \
    gdb \
    valgrind \
    strace \
    man-db \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN make || true

CMD ["/bin/bash"]
