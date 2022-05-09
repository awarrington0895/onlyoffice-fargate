FROM gitpod/workspace-full

RUN brew update

RUN brew install hashicorp/tap/terraform

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && sudo ./aws/install
