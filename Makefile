.PHONY: usage

# Echo available commands
usage:
	@echo "Usage: make [command]"
	@echo ""
	@echo "Commands:"
	@echo "  install         Install dependencies"
	@echo "  dev             Start development server"
	@echo "  start           Start production server"
	@echo "  cf-describe     Describe Copilot CloudFormation stack"



# Development
install:
	@echo "Installing dependencies"
	@poetry install

dev:
	@echo "Starting development server"
	@poetry run python manage.py runserver

start:
	@echo "Starting production server"
	@poetry run gunicorn example_project.wsgi:application --bind 127.0.0.1:8000


# Check copilot stack status
cf-describe:
	@echo "Describing Copilot CloudFormation stack"
	@aws cloudformation describe-stacks --stack-name ${COPILOT_APP_NAME}-${COPILOT_ENV_NAME}
