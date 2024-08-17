FROM --platform=$BUILDPLATFORM python:alpine AS base
WORKDIR /app
COPY requirements.txt
