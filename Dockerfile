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
    maintainer="karansharma1295@gmail.com"
# Use HTTPS repo for downloading Alpine packages
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories 
# Download kubectl
RUN apk update && \ 
    apk add --no-cache curl ca-certificates && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
# Install kubectl (stable, latest version)
RUN mv kubectl /usr/local/bin \
    && chmod +x /usr/local/bin/kubectl
# Install awscli
RUN pip install awscli
# Install aws-iam-authenticator (URL Specified via build arg)
ARG AWS_IAM_AUTHENTICATOR_URL=https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
RUN curl -o /usr/local/bin/aws-iam-authenticator $AWS_IAM_AUTHENTICATOR_URL
RUN chmod +x /usr/local/bin/aws-iam-authenticator
# Install sops
ARG SOPS_RELEASE_URL=https://github.com/mozilla/sops/releases/download/3.3.1/sops-3.3.1.linux
RUN curl -o /usr/local/bin/sops $SOPS_RELEASE_URL
RUN chmod +x /usr/local/bin/sops
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