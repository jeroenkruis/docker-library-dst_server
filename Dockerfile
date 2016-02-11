FROM debian:jessie
MAINTAINER Jeroen Kruis <kruisjeroen@gmail.com>

RUN dpkg --add-architecture i386 && apt-get update \
  && apt-get install -y curl lib32gcc1 lib32stdc++6 libgcc1 libcurl4-gnutls-dev:i386 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -u 10999 -m steam
RUN mkdir /DST \
  && chown steam:steam /DST \
  && mkdir -p /home/steam/.klei/DoNotStarveTogether \
  && chown -R steam:steam /home/steam/.klei

USER steam
RUN mkdir ~/steamcmd
ENV DST_SERVER_VERSION 161659
RUN cd  ~/steamcmd && curl -SLO "http://media.steampowered.com/installer/steamcmd_linux.tar.gz" \
  && tar -xvf steamcmd_linux.tar.gz -C ~/steamcmd && rm steamcmd_linux.tar.gz
RUN ~/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/steamapps/DST +app_update 343050 validate +quit

COPY ./config/modoverrides.lua /home/steam/.klei/DoNotStarveTogether
COPY ./config/dedicated_server_mods_setup.lua /home/steam/steamapps/DST/mods

USER root
ADD ./bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/run-dst

USER steam
EXPOSE 10999/udp
VOLUME ["/DST"]
ENTRYPOINT ["/usr/local/bin/run-dst"]
