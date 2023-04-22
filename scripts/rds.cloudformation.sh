#!/bin/bash
set -eu

# Check args and show usage if needed
if [ $# -ne 1 ]; then
  echo "Usage: $0 <command>" 1>&2
  echo "Commands: create-cf-stack, plan-cf, deploy-cf, delete-cf validate-cf" 1>&2
  exit 1
fi

# Check all required env vars are set
if [ -z "${DEPLOY_RDS_STACK_NAME}" ]; then
  echo "env DEPLOY_RDS_STACK_NAME is not set" 1>&2
  exit 1
fi

# Create a new CloudFormation stack
if [ "$1" = "create-cf-stack" ]; then
  echo "Creating CloudFormation stack"
  aws cloudformation create-stack \
    --stack-name "${DEPLOY_RDS_STACK_NAME}" \
    --template-body ./cloudformation/rds.template.yml \
    --cli-input-yaml ./cloudformation/rds.parameters.yml
  echo -e "\033[32mSUCCESS\033[0m: CloudFormation stack ${DEPLOY_RDS_STACK_NAME} created\n"

  exit 0
fi

# Plan a CloudFormation stack
if [ "$1" = "plan-cf" ]; then
  echo "Planning CloudFormation stack"
  # shellcheck disable=SC2046
  aws cloudformation deploy \
    --no-execute-changeset \
    --stack-name "${DEPLOY_RDS_STACK_NAME}" \
    --template-file ./cloudformation/rds.template.yml \
    --parameter-overrides $(cat ./cloudformation/rds.parameters.properties)
  echo -e "\033[32mSUCCESS\033[0m: CloudFormation stack ${DEPLOY_RDS_STACK_NAME} planned\n"

  exit 0
fi

# Deploy a CloudFormation stack
if [ "$1" = "deploy-cf" ]; then
  echo "Deploying CloudFormation stack"
  # shellcheck disable=SC2046
  aws cloudformation deploy \
    --stack-name "${DEPLOY_RDS_STACK_NAME}" \
    --template-file ./cloudformation/rds.template.yml \
    --parameter-overrides $(cat ./cloudformation/rds.parameters.properties)
  echo -e "\033[32mSUCCESS\033[0m: CloudFormation stack ${DEPLOY_RDS_STACK_NAME} deployed\n"

  exit 0
fi


# Delete a CloudFormation stack
if [ "$1" = "delete-cf" ]; then
  echo "Deleting CloudFormation stack"
  aws cloudformation delete-stack \
    --stack-name "${DEPLOY_RDS_STACK_NAME}"
  echo -e "\033[32mSUCCESS\033[0m: CloudFormation stack ${DEPLOY_RDS_STACK_NAME} deleted\n"

  exit 0
fi

# Validate a CloudFormation stack
if [ "$1" = "validate-cf" ]; then
  echo "Validating CloudFormation stack"
  aws cloudformation validate-template \
    --template-body file://cloudformation/rds.template.yml
  echo -e "\033[32mSUCCESS\033[0m: CloudFormation stack ${DEPLOY_RDS_STACK_NAME} validated\n"

  exit 0
fi
