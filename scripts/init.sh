#!/bin/bash

echo "Waiting for database to be ready..."
until pg_isready -h db -U postgres -d gobid; do
  sleep 1
done

echo "Creating database if doesn't exists..."
psql -h db -U postgres -c "CREATE DATABASE gobid;" || true

echo "Applying migrations..."
cd /app/internal/store/pgstore/migrations
tern migrate

echo "Staring application"
cd /app

exec ./main
