#!/bin/bash
set -eu

# Check args and show usage if needed
if [ $# -ne 1 ]; then
  echo "Usage: $0 <command>" 1>&2
  echo "Commands: create-app, deploy-env, deploy-svc, delete-app, exec-svc" 1>&2
  exit 1
fi

# Check all required env vars are set
if [ -z "${COPILOT_APP_NAME}" ]; then
  echo "env COPILOT_APP_NAME is not set" 1>&2
  exit 1
fi
if [ -z "${COPILOT_APP_BASE_DOMAIN}" ]; then
  echo "env COPILOT_APP_BASE_DOMAIN is not set" 1>&2
  exit 1
fi
if [ -z "${COPILOT_ENV_NAME}" ]; then
  echo "env COPILOT_ENV_NAME is not set" 1>&2
  exit 1
fi
if [ -z "${COPILOT_SERVICE_NAME}" ]; then
  echo "env COPILOT_SERVICE_NAME is not set" 1>&2
  exit 1
fi


# Create a new Copilot application
if [ "$1" = "create-app" ]; then
  echo "Initializing Copilot Application..."
  echo "exec: copilot app init ${COPILOT_APP_NAME} --domain ${COPILOT_APP_BASE_DOMAIN}"
  copilot app init "${COPILOT_APP_NAME}" --domain "${COPILOT_APP_BASE_DOMAIN}"
  echo -e "\033[32mSUCCESS\033[0m: Copilot Application ${COPILOT_APP_NAME} initialized\n"

  echo "Initializing Copilot Environment..."
  echo "exec: copilot env init --name ${COPILOT_ENV_NAME} --profile ${AWS_PROFILE} --default-config"
  copilot env init --name "${COPILOT_ENV_NAME}" --profile "${AWS_PROFILE}" --default-config
  echo -e "\033[32mSUCCESS\033[0m: Copilot Environment ${COPILOT_ENV_NAME} initialized\n"

  echo "Deploying Copilot Environment..."
  echo "exec: copilot env deploy --name ${COPILOT_ENV_NAME}"
  copilot env deploy --name "${COPILOT_ENV_NAME}"
  echo -e "\033[32mSUCCESS\033[0m: Copilot Environment ${COPILOT_ENV_NAME} deployed\n"

  echo "Initializing Copilot Service..."
  echo "exec: copilot svc init --name ${COPILOT_SERVICE_NAME} --svc-type Load Balanced Web Service --dockerfile ./Dockerfile"
  copilot svc init --name "${COPILOT_SERVICE_NAME}" --svc-type "Load Balanced Web Service" --dockerfile ./Dockerfile
  echo -e "\033[32mSUCCESS\033[0m: Copilot Service ${COPILOT_SERVICE_NAME} initialized\n"

  echo "Deploying Copilot Service..."
  echo "exec: copilot svc deploy --name ${COPILOT_SERVICE_NAME} --env ${COPILOT_ENV_NAME}"
  copilot svc deploy --name "${COPILOT_SERVICE_NAME}" --env "${COPILOT_ENV_NAME}"
  echo -e "\033[32mSUCCESS\033[0m: Copilot Service ${COPILOT_SERVICE_NAME} deployed\n"

  exit 0
fi

# Deploy the Copilot environment
if [ "$1" = "deploy-env" ]; then
  echo "Deploying Copilot Environment..."
  echo "exec: copilot env deploy --name ${COPILOT_ENV_NAME} --app ${COPILOT_APP_NAME}"
  copilot env deploy --name "${COPILOT_ENV_NAME}" --app "${COPILOT_APP_NAME}"
  echo -e "\033[32mSUCCESS\033[0m: Copilot environment ${COPILOT_ENV_NAME} deployed\n"

  exit 0
fi

# Deploy the Copilot service
if [ "$1" = "deploy-svc" ]; then
  echo "Deploying Copilot Service..."
  echo "exec: copilot svc deploy --name ${COPILOT_SERVICE_NAME} --env ${COPILOT_ENV_NAME}"
  copilot svc deploy --name "${COPILOT_SERVICE_NAME}" --env "${COPILOT_ENV_NAME}"
  echo -e "\033[32mSUCCESS\033[0m: Copilot Service ${COPILOT_SERVICE_NAME} deployed\n"

  exit 0
fi

# Delete the Copilot application
if [ "$1" = "delete-app" ]; then
  echo "Deleting Copilot Application..."
  echo "exec: copilot app delete --name ${COPILOT_APP_NAME}"
  copilot app delete --name "${COPILOT_APP_NAME}"
  echo -e "\033[32mSUCCESS\033[0m: Copilot Application ${COPILOT_APP_NAME} deleted\n"

  exit 0
fi

# Execute a command in the Copilot service
if [ "$1" = "exec-svc" ]; then
  echo "Executing command in Copilot Service..."
  echo "exec: copilot svc exec --app ${COPILOT_APP_NAME} --name ${COPILOT_SERVICE_NAME} --env ${COPILOT_ENV_NAME}"
  copilot svc exec --app "${COPILOT_APP_NAME}" --name "${COPILOT_SERVICE_NAME}" --env "${COPILOT_ENV_NAME}"
  echo -e "\033[32mSUCCESS\033[0m: Copilot Service ${COPILOT_SERVICE_NAME} executed\n"

  exit 0
fi
