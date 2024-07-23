FROM ubuntu:22.04
USER root
RUN  apt-get update \
  && apt-get install -y wget \
  && apt-get upgrade \
  && rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/BeamMP/BeamMP-Server/releases/download/v3.4.1/BeamMP-Server.ubuntu.20.04.x86_64 
RUN chmod +x ./BeamMP-Server.ubuntu.20.04.x86_64 
RUN ./BeamMP-Server.ubuntu.20.04.x86_64