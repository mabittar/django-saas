###########
# BUILDER #
###########

# pull official base image
FROM python:3.11.4-slim-buster AS builder

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc \
    && rm -rf /var/lib/apt/lists/*

# install app deps
RUN pip install --upgrade pip
COPY ./src /usr/src/app/

# install python dependencies
COPY ./requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt


#########
# FINAL #
#########

# pull official base image
FROM python:3.11.4-slim-buster

ARG DJANGO_SECRET_KEY
ENV DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}

ARG DJANGO_DEBUG=0
ENV DJANGO_DEBUG=${DJANGO_DEBUG}

# set the Django default project name
ENV PROJ_NAME=src

# create directory for the app user
RUN mkdir -p /home/app

# create the app user
# RUN addgroup --system app && adduser --system --group app

# create the appropriate directories
ENV HOME=/home/app
ENV APP_HOME=/home/app/web
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends netcat
COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache /wheels/*

# copy project files and set ownership
# COPY --chown=app:app ./src .
COPY ./src .

ARG DJANGO_SECRET_KEY
ENV DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}

ARG DJANGO_DEBUG=0
ENV DJANGO_DEBUG=${DJANGO_DEBUG}

# copy run script and set permissions
# COPY --chown=app:app ./start_up.sh .
RUN python manage.py pull_vendors_static
RUN python manage.py migrate --no-input
COPY ./start_up.sh .
RUN chmod +x start_up.sh
RUN sed -i 's/\r//g' ./start_up.sh


# change to the app user
# USER app

# Run the Django project via the runtime script
# when the container starts
CMD ["./start_up.sh"]
