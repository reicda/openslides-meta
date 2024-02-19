#!/bin/bash

until pg_isready -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER"; do
  echo "Waiting for Postgres server '$POSTGRES_HOST' to become available..."
  sleep 3
done

