FROM cimg/deploy:2023.04.1
RUN sudo apt-get update && sudo apt-get upgrade -y
RUN echo echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.asc \
    sudo apt-get update && sudo apt-get install google-cloud-cli
RUN gcloud components install gke-gcloud-auth-plugin \
    gcloud --quiet config set core/disable_usage_reporting true \
    gcloud --quiet config set component_manager/disable_update_check true