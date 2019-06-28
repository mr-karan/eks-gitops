#!/bin/sh
set -e
if ! which aws > /dev/null; then
        echo "Can't find 'aws cli' executable. Aborted."
        exit 1
fi
if [[ -z "${CLUSTER_REGION}" ]]; then
        echo "Missing env variable: CLUSTER_REGION"
        exit 1
fi
if [[ -z "${CLUSTER_NAME}" ]]; then
        echo "Missing env variable: CLUSTER_NAME"
        exit 1
fi
aws sts get-caller-identity
aws eks --region $CLUSTER_REGION update-kubeconfig --name $CLUSTER_NAME
exec "$@"
