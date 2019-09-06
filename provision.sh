#!/bin/bash

TERRAFORM_IMAGE=hashicorp/terraform:0.12.8
TERRAFORM_CMD="docker run -ti --rm -w /app -v ${HOME}/.aws:/root/.aws -v ${HOME}/.ssh:/root/.ssh -v `pwd`:/app ${TERRAFORM_IMAGE}"
${TERRAFORM_CMD} init -upgrade
${TERRAFORM_CMD} destroy
${TERRAFORM_CMD} apply
