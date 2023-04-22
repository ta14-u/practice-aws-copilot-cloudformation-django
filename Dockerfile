FROM python:3.11-slim

# Setup environment
ENV APP_HOME=/usr/src/app
RUN mkdir -p $APP_HOME

# Setup user
RUN useradd -ms /bin/bash app

# Setup workdir
WORKDIR $APP_HOME

# Install system dependencies
RUN apt-get update && apt-get -y install \
    gcc \
    libmariadb-dev

# Copy application requirements
COPY apps $APP_HOME/apps
COPY example_project $APP_HOME/example_project
COPY manage.py $APP_HOME

# Copy poetry files
COPY pyproject.toml $APP_HOME
COPY poetry.lock $APP_HOME

# Copy env files
COPY .env.app $APP_HOME

# Copy entrypoint
COPY docker-entrypoint.app.sh $APP_HOME

# Change ownership
RUN chown -R app:app $APP_HOME

# Create data directory
RUN mkdir -p /var/data && chown -R app:app /var/data

# Switch to app user
USER app

# Setup poetry
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir poetry

# Add poetry bin to path
ENV PATH $PATH:/home/app/.local/bin

# Allow entrypoint to be executable
RUN chmod u+x $APP_HOME/docker-entrypoint.app.sh

# Install dependencies
RUN poetry install --only main

# Expose port
EXPOSE 8000
