FROM cimg/gcp:2023.09.1
RUN sudo apt-get update && sudo apt-get upgrade -y
RUN	HELM_VER=3.11.1 && \
	curl -sSL "https://get.helm.sh/helm-v${HELM_VER}-linux-amd64.tar.gz" | sudo tar -xz --strip-components=1 -C /usr/local/bin linux-amd64/helm && \
	helm version