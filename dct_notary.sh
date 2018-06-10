#!/bin/bash
#this script will create, curl and unpack a client bundle

if [ -z ${NOTARY_OPTS+x} ]; then
  echo Setting variables for you...
  . ./var_setup.sh
fi

export NAMESPACE="ci"
export REPO="dc18"
export ROLE="demo"

# initialize repository in notary
notary ${NOTARY_OPTS} init ${DTR_URL}/${NAMESPACE}/${REPO}

# publish locally staged changes
notary ${NOTARY_OPTS} publish ${DTR_URL}/${NAMESPACE}/${REPO}

# rotate snapshot key and change it to server managed
notary ${NOTARY_OPTS} key rotate ${DTR_URL}/${NAMESPACE}/${REPO} snapshot --server-managed

# create delegation for 'targets/releases' role
notary ${NOTARY_OPTS} delegation add -p ${DTR_URL}/${NAMESPACE}/${REPO} targets/releases --all-paths cert.pem

# create delegation for 'targets/${ROLE}' role
notary ${NOTARY_OPTS} delegation add -p ${DTR_URL}/${NAMESPACE}/${REPO} targets/${ROLE} --all-paths cert.pem

# show delegations
notary ${NOTARY_OPTS} delegation list ${DTR_URL}/${NAMESPACE}/${REPO}

# load the key on the client
notary ${NOTARY_OPTS} key import key.pem

# enable DCT
export DOCKER_CONTENT_TRUST=1

#push signed image
docker tag ${DTR_URL}/${NAMESPACE}/dc18_build:0.3 ${DTR_URL}/${NAMESPACE}/${REPO}:0.3
docker push ${DTR_URL}/${NAMESPACE}/${REPO}:0.3
