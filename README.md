<a href="https://zerodha.tech"><img src="https://zerodha.tech/static/images/github-badge.svg" align="right" /></a>

# eks-gitops

[Docker Hub](https://hub.docker.com/repository/docker/mrkaran/eks-gitops)

`docker pull mrkaran/eks-gitops:latest`

An alpine based image which containts `kubectl`, `aws`, `aws-iam-authenticator` and `kubeval`. Useful if you are running an EKS Cluster
and want to use these tools in a Continuos Deployment environment. It additionally configures `KUBECONFIG` to use
`aws-iam-authenticator` which is required if you're running the same (by default enabled on all EKS clusters).

You can run this out of the box, provided the container has access to atleast one of the AWS supported auth credentials.

Note: You must specify `CLUSTER_REGION` and `CLUSTER_NAME` as environment variables in your CD pipeline for the script in
`ENTRYPOINT` to work.
