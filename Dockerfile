FROM python:3.11-slim

# Setup arg variables
ARG USERNAME=app
ARG APP_USER_HOME=/home/${USERNAME}

# Setup system dependencies
RUN apt-get update && apt-get -y install \
    gcc \
    libmariadb-dev

# Setup user
RUN useradd -m -s /bin/bash ${USERNAME}

# Switch to app user
USER ${USERNAME}

# Setup environment
ENV WORKSPACE=${APP_USER_HOME}/workspace

# Setup workdir
RUN mkdir -p ${WORKSPACE}
WORKDIR ${WORKSPACE}

# Copy application requirements
COPY --chown=${USERNAME}:${USERNAME} apps ${WORKSPACE}/apps
COPY --chown=${USERNAME}:${USERNAME} example_project ${WORKSPACE}/example_project
COPY --chown=${USERNAME}:${USERNAME} manage.py \
                                     pyproject.toml \
                                     poetry.lock \
                                     .env.app \
                                     docker-entrypoint.app.sh ${WORKSPACE}

# Setup poetry
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir poetry

# Add poetry bin to path
ENV PATH $PATH:${APP_USER_HOME}/.local/bin

# Allow entrypoint to be executable
RUN chmod u+x ${WORKSPACE}/docker-entrypoint.app.sh

# Install dependencies
RUN poetry install --only main

# Expose port
EXPOSE 8000
