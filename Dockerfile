# Base Image (Python because aws cli needs to be installed and pip install is the quickest/easiest way)
FROM python:3.7.3-alpine3.9
# Build Time Args (Refer to Makefile)
ARG VCS_REF
ARG BUILD_DATE
# Metadata (Refer to http://label-schema.org/rc1/)
LABEL org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/mr-karan/Dockerfiles" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.name="eks-kubectl" \
    org.label-schema.description="Kubectl configured with AWS tools like aws-cli and aws-iam-authenticator. Useful for CI/CD Environments" \
    maintainer="hello@mrkaran.dev"
# Use HTTPS repo for downloading Alpine packages
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories 
# Download kubectl
RUN apk update && \ 
    apk add --no-cache curl git ca-certificates gettext make && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
# Install kubectl (stable, latest version)
RUN mv kubectl /usr/local/bin \
    && chmod +x /usr/local/bin/kubectl
# Install awscli
RUN pip install awscli
# Install aws-iam-authenticator (URL Specified via build arg)
ARG AWS_IAM_AUTHENTICATOR_URL=https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
RUN curl -o /usr/local/bin/aws-iam-authenticator $AWS_IAM_AUTHENTICATOR_URL
RUN chmod +x /usr/local/bin/aws-iam-authenticator
# Install kubeval
ARG KUBEVAL_RELEASE_URL=https://github.com/instrumenta/kubeval/releases/download/0.14.0/kubeval-linux-amd64.tar.gz
RUN curl -sL $KUBEVAL_RELEASE_URL | tar xz && mv kubeval /usr/local/bin/
RUN chmod +x /usr/local/bin/kubeval
# Install kustomize
ARG KUSTOMIZE_RELEASE_URL=https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.5.3/kustomize_v3.5.3_linux_amd64.tar.gz
RUN curl -sL $KUSTOMIZE_RELEASE_URL | tar xz && mv kustomize /usr/local/bin/
RUN chmod +x /usr/local/bin/kustomize
# Install kubekutr
ARG KUBEKUTR_RELEASE_URL=https://github.com/mr-karan/kubekutr/releases/download/v0.8.8/kubekutr_0.8.8_linux_amd64.tar.gz
RUN curl -sL $KUBEKUTR_RELEASE_URL | tar xz && mv kubekutr /usr/local/bin/
RUN chmod +x /usr/local/bin/kubekutr
# Install promtool
# ARG PROMETHEUS_VERSION=2.15.2
# RUN wget -O prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz && \
#     mkdir /prometheus && \
#     tar -xvf prometheus.tar.gz -C /prometheus --strip-components 1 --exclude */promtool && \
#     rm prometheus.tar.gz
# Add binaries to PATH
ENV PATH /usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/user/.local/bin
# Create a default user
RUN addgroup -S eksgroup && adduser -S eksuser -G eksgroup
USER eksuser
WORKDIR /home/eksuser
# Use aws eks to update your kubectl config based on the IAM role the container assumes
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
# Default command to run when container spawns
CMD ["kubectl", "help"]