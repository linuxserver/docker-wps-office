# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:arch

# set version label
ARG BUILD_DATE
ARG VERSION
ARG WPSOFFICE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=WPS-Office \
    NO_FULL=true \
    NO_GAMEPAD=true

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/wps-office-icon.png && \
  echo "**** install packages ****" && \
  pacman -Sy --noconfirm --needed \
    chromium \
    git \
    qt6-base \
    tint2 \
    thunar && \
  echo "**** install sfwbar ****" && \
  cd /tmp && \
  git clone https://aur.archlinux.org/sfwbar.git && \
  chown -R abc:abc sfwbar && \
  cd sfwbar && \
  sudo -u abc makepkg -sAci --skipinteg --noconfirm --needed && \
  echo "**** install wps-office ****" && \
  cd /tmp && \
  git clone https://aur.archlinux.org/wps-office-cn.git && \
  chown -R abc:abc wps-office-cn && \
  cd wps-office-cn && \
  sudo -u abc makepkg -sAci --skipinteg --noconfirm --needed && \
  mkdir /tmp/fonts && \
  curl -o \
    /tmp/fonts.tar.gz -L \
    "https://github.com/BannedPatriot/ttf-wps-fonts/archive/refs/heads/master.tar.gz" && \
  tar xf \
    /tmp/fonts.tar.gz -C \
    /tmp/fonts/ --strip-components=1 && \
  cd /tmp/fonts && \
  bash install.sh && cd / && \
  ln -s \
    /usr/lib/libtiff.so.6 \
    /usr/lib/libtiff.so.5 && \
  echo "**** application tweaks ****" && \
  mv \
    /usr/bin/chromium \
    /usr/bin/chromium-real && \
  mv \
    /usr/bin/thunar \
    /usr/bin/thunar-real && \
  echo "**** cleanup ****" && \
  pacman -Rsn --noconfirm \
    git \
    $(pacman -Qdtq) && \
  rm -rf \
    /tmp/* \
    /var/cache/pacman/pkg/* \
    /var/lib/pacman/sync/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001

VOLUME /config
