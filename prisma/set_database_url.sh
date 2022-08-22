#!/bin/bash

export DB_CONTAINER_HOST=$(dig db +short)
export DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_CONTAINER_HOST}:5432/${DATABASE_NAME}?schema=public"
