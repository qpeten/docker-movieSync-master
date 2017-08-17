# Created by Quentin Peten on the 17th of August 2017
# This container is supposed to create and seed a torrent file per folder (=movie)

FROM ubuntu:16.04

ENV UID 1000
ENV GID 1000

RUN apt-get update -q && \
    apt-get install -qy

RUN apt-get install -y transmission transmission-cli transmission-daemon

RUN groupadd -g $GID user
RUN useradd --no-create-home -g user --uid $UID user

COPY ./launch.bash /launch.bash
RUN chmod 755 /launch.bash && chown user /launch.bash

VOLUME /transmission-config
VOLUME /movies
VOLUME /torrents

USER user

CMD ["/launch.bash"]
