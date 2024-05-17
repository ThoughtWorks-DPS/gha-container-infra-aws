FROM twdps/gha-container-base-image:0.2.0

LABEL org.opencontainers.image.title="gha-container-infra-aws" \
      org.opencontainers.image.description="Alpine-based github actions job container image" \
      org.opencontainers.image.documentation="https://github.com/ThoughtWorks-DPS/gha-container-infra-aws" \
      org.opencontainers.image.source="https://github.com/ThoughtWorks-DPS/gha-container-infra-aws" \
      org.opencontainers.image.url="https://github.com/ThoughtWorks-DPS/gha-container-infra-aws" \
      org.opencontainers.image.vendor="ThoughtWorks, Inc." \
      org.opencontainers.image.authors="nic.cheneweth@thoughtworks.com" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.created="CREATED" \
      org.opencontainers.image.version="VERSION"

ENV TERRAFORM_VERSION=1.8.2
ENV TERRAFORM_SHA256SUM=74f3cc4151e52d94e0ecbe900552adc9b8440b4a8dc12f7fdaab2d0280788acc
ENV TFLINT_VERSION=0.51.0
ENV TRIVY_VERSION=0.51.1
ENV AWSCLI_VERSION=1.32.25
ENV CHECKOV_VERSION=3.2.71
ENV COSIGN_VERSION=2.2.4

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# sudo since twdps circleci remote docker images set the USER=cirlceci
# hadolint ignore=DL3004
RUN sudo bash -c "echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories" && \
    sudo apk add --no-cache \
             nodejs-current==21.7.2-r0 \
             npm==10.2.5-r0 \
             ruby==3.2.4-r0 \
             ruby-dev==3.2.4-r0 \
             ruby-webrick==1.8.1-r0 \
             ruby-bundler==2.4.15-r0 \
             python3==3.11.9-r0 \
             python3-dev==3.11.9-r0 \
             perl-utils==5.38.2-r0 \
             libffi-dev==3.4.4-r3 && \
    sudo rm /usr/lib/python3.11/EXTERNALLY-MANAGED && \
    sudo python3 -m ensurepip && \
    sudo rm -r /usr/lib/python*/ensurepip && \
    sudo pip3 install --upgrade pip==24.0 && \
    if [ ! -e /usr/bin/pip ]; then sudo ln -s /usr/bin/pip3 /usr/bin/pip ; fi && \
    sudo ln -s /usr/bin/pydoc3 /usr/bin/pydoc && \
    sudo pip install --no-binary \
             setuptools==69.5.1 \
             wheel==0.43.0 \
             invoke==2.2.0 \
             requests==2.31.0 \
             jinja2==3.1.3 \
             iam-credential-rotation==0.2.2 \
             checkov=="${CHECKOV_VERSION}" \
             awscli=="${AWSCLI_VERSION}" && \
    sudo npm install -g \
             snyk@1.1291.0 \
             github-release-notes@0.17.3 \
             bats@1.11.0 && \
    sudo sh -c "echo 'gem: --no-document' > /etc/gemrc" && \
    sudo gem install \
             awspec:1.30.0 \
             inspec-bin:5.22.36 \
             json:2.7.2 && \
    curl -SLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    sha256sum -cs "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && sudo rm "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    sudo unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/local/bin && \
    sudo rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    curl -SLO "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip" > tflint_linux_amd64.zip && \
    sudo unzip tflint_linux_amd64.zip -d /usr/local/bin && \
    sudo rm tflint_linux_amd64.zip && \
    curl -LO "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" && \
    tar xzf "trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" trivy && \
    sudo mv trivy /usr/local/bin && rm "trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" && \
    curl -LO "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-amd64" && \
    chmod +x cosign-linux-amd64 && sudo mv cosign-linux-amd64 /usr/local/bin/cosign

    COPY inspec /etc/chef/accepted_licenses/inspec