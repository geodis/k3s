FROM ubuntu:20.04

ARG USER
ARG USER_ID

ENV TERRAFORM_VERSION=1.1.7
ENV TERRAGRUNT_VERSION=0.36.6
ENV TZ=Europe/Madrid
ENV HELM_VERSION 3.4.2
ENV KUBECTL_VERSION=${KUBECTL_VERSION:-1.22.4}
ENV KUBECTX_VERSION=${KUBECTX_VERSION:-0.9.4}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  echo $TZ > /etc/timezone

RUN apt update && \
  apt install -y \
  bsdmainutils \
  strace \
  curl \
  git \
  graphviz \
  iputils-ping \
  python3-pip \
  telnet \
  tree \
  vim \
  jq \
  unzip \
  cowsay && \
  rm -rf /var/lib/apt/lists/*
  
#pip
RUN python3 -m pip install --upgrade pip && pip check
COPY requirements.txt ./
RUN pip3 --no-cache-dir install -r requirements.txt

# H3lm
RUN curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz && \
  tar -xvf helm.tar.gz && \
  mv linux-amd64/helm /usr/local/bin/helm && \
  chmod +x /usr/local/bin/helm && \
  rm -rf linux-amd64 && \
  rm helm.tar.gz

# kube-ps1
RUN curl -sL https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh -o /usr/local/bin/kube-ps1.sh && \
  chmod +x /usr/local/bin/kube-ps1.sh

# kubectl
RUN curl -sL https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl

# kubectx / kubens
RUN curl -sL https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/kubectx -o /usr/local/bin/kubectx && \
  curl -sL https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/kubens -o /usr/local/bin/kubens && \
  chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens

RUN curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz && \
  tar -xvf helm.tar.gz && \
  mv linux-amd64/helm /usr/local/bin/helm && \
  chmod +x /usr/local/bin/helm && \
  rm -rf linux-amd64 && \
  rm helm.tar.gz

# terraform
RUN apt update && \
    apt install -y unzip && \
    curl -sL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin && \
    rm terraform.zip && \
    apt purge --auto-remove -y unzip && \
    rm -rf /var/lib/apt/lists/*

# terragrunt
RUN curl -sL https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

RUN useradd -m -u $USER_ID $USER

USER $USER

RUN echo "alias ll='ls -la'" >> ~/.bashrc && \
  echo "alias tf='terraform'" >> ~/.bashrc &&  \
  echo "alias tg='terragrunt'" >> ~/.bashrc &&  \
  echo "alias k='kubectl'" >> ~/.bashrc && \
  echo "alias ktx='kubectx'" >> ~/.bashrc && \
  echo "alias kns='kubens'" >> ~/.bashrc &&  \
  echo "alias hi='helm upgrade --install device-limit /app/helm --no-hooks=false --wait -f /app/helm/values.yaml -f /app/helm/values-override.yaml  --namespace=qa2'" >> ~/.bashrc &&  \
  echo "source /usr/local/bin/kube-ps1.sh" >> ~/.bashrc &&  \
  echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc &&  \
  echo "PATH=$PATH:~/bin" >> ~/.bashrc && \
  echo "PS1='[\e[0;33m\$(git branch 2>/dev/null | grep '^*'| colrm 1 2)\e[m]\$ '" >> ~/.bashrc

WORKDIR /app
