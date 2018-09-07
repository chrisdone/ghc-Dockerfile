FROM debian:stretch-slim
MAINTAINER Chris Done

RUN apt-get update && apt-get install -y \
       # Needed for adding the PPA key
       gnupg \
       gpgv && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80  --recv-keys BA3CBA3FFE22B574 \
      && echo 'deb     http://downloads.haskell.org/debian stretch main' >> /etc/apt/sources.list.d/haskell.list && \

   apt-get update && apt-get install -y \

    # from darinmorrison/haskell, related to ncurses, not sure if it is needed
    libtinfo5 \

    # mentioned on the GHC wiki
    autoconf automake libtool make libgmp-dev ncurses-dev g++ python bzip2 ca-certificates \
    xz-utils \

    ## install minimal set of haskell packages
    # from darinmorrison/haskell
    ghc-8.2.2 \
    alex \
    cabal-install-2.2 \
    happy \

    # development conveniences
    sudo xutils-dev \
    && apt-get install git -y \
    && apt-get clean

ENV LANG     C.UTF-8
ENV LC_ALL   C.UTF-8
ENV LANGUAGE C.UTF-8

# Getting the GHC sources
# -----------------------
#   [2]: https://ghc.haskell.org/trac/ghc/wiki/Building/GettingTheSources
#
RUN cd; \
    mkdir ghc_build; \
    cd ghc_build; \
    git clone -b ghc-8.0 --recursive git://git.haskell.org/ghc.git ghc-8.0; \
    cd ghc-8.0; \
    git checkout ghc-8.0; \
    git submodule update --init

RUN apt-get install ghc -y

# Building
# --------
#   [3]: https://ghc.haskell.org/trac/ghc/wiki/Building/QuickStart
#
RUN cd; \
    cd ghc_build/ghc-8.0; \
    cd mk; \
    sed -e 's/^#BuildFlavour = quickest$/BuildFlavour = quickest/' \
        build.mk.sample > build.mk; \
    cd ..; \
    ./boot

RUN cd; cd ghc_build/ghc-8.0 &&  ./configure

RUN cd; cd ghc_build/ghc-8.0 && make -j5
