FROM ubuntu:22.04
USER root
WORKDIR /app
COPY ServerConfig.toml /app/ServerConfig.toml
RUN  apt-get update \
  && apt-get install -y wget liblua5.3-0 \
  && apt-get upgrade \
  && rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/BeamMP/BeamMP-Server/releases/download/v3.4.1/BeamMP-Server.ubuntu.22.04.x86_64 \
	&& chmod +x ./BeamMP-Server.ubuntu.22.04.x86_64 \
    && ./BeamMP-Server.ubuntu.22.04.x86_64