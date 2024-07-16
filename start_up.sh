#!/bin/bash

RUN_PORT=${PORT:-8000}

gunicorn home.wsgi:application --bind "0.0.0.0:$RUN_PORT"
