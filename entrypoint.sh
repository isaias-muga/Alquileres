#!/bin/sh
set -e

# Wait for DB to be ready
if [ -n "${DB_HOST}" ]; then
  echo "Waiting for database at ${DB_HOST}:${DB_PORT:-3306}..."
  until nc -z ${DB_HOST} ${DB_PORT:-3306}; do
    sleep 1
  done
fi

# Apply migrations
python manage.py migrate --noinput

# Collect static files
python manage.py collectstatic --noinput

# Start Gunicorn
exec gunicorn myweb.wsgi:application --bind 0.0.0.0:8000 --workers 3
