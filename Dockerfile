# Set the python version as a build-time argument
# with Python 3.12 as the default
ARG PYTHON_VERSION=3.12-slim-bullseye
FROM python:${PYTHON_VERSION}


# Upgrade pip
RUN pip install --upgrade pip

# Set Python-related environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_ROOT_USER_ACTION=ignore


# Install os dependencies for our mini vm
RUN apt-get update && apt-get install -y \
    # for postgres
    libpq-dev \
    # for Pillow
    libjpeg-dev \
    # for CairoSVG
    libcairo2 \
    # other
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Clean up apt cache to reduce image size
RUN apt-get remove --purge -y \
    && apt-get autoremove -y \
    && apt-get clean

# Create a custom user with UID 1234 and GID 1234
RUN groupadd -g 1234 customgroup && \
    useradd -m -u 1234 -g customgroup customuser

WORKDIR /home/customuser

# Copy the requirements file into the container
COPY requirements.txt requirements.txt
COPY paracord_runner.sh paracord_runner.sh

# copy the project code into the container's working directory
COPY ./src .

# Install the Python project requirements
RUN python -m venv venv
RUN venv/bin/pip install -r requirements.txt 

RUN chown -R customuser:customgroup ./
USER customuser

# database isn't available during build
# run any other commands that do not need the database
# such as:
# RUN python manage.py collectstatic --noinput

# set the Django default project name
ARG PROJ_NAME="saas-django"

# make the bash script executable
RUN chmod +x paracord_runner.sh

# Run the Django project via the runtime script
# when the container starts
CMD ./paracord_runner.sh