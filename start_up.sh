#!/bin/bash

RUN_PORT=${PORT:-8000}

python manage.py pull_vendors_static
python manage.py collectstatic --no-input
python manage.py migrate --no-input
gunicorn home.wsgi:application --bind "0.0.0.0:$RUN_PORT"
