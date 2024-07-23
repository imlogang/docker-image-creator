FROM ubuntu:22.04
RUN wget https://github.com/BeamMP/BeamMP-Server/releases/download/v3.4.1/BeamMP-Server.ubuntu.20.04.x86_64 \
	&& chmod +x ./BeamMP-Server.ubuntu.20.04.x86_64 \
	&& ./BeamMP-Server.ubuntu.20.04.x86_64