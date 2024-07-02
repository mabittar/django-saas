#!/bin/bash


source venv/bin/activate
RUN_PORT=${PORT:-8000}
python manage.py migrate --no-input
gunicorn ${PROJ_NAME}.wsgi:application --bind \"0.0.0.0:\$RUN_PORT\