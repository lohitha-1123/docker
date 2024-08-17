FROM --platform=$BUILDPLATFORM python:alpine AS base
WORKDIR /app
COPY requirements.txt
RUN pip install -r requirements.txt

FROM --platform=$BUILDPLATFORM node:18-alpine AS app-base
WORKDIR /app
COPY app/packages.json app/yarn.lock ./
COPY app/src ./src

FROM app-base AS test
RUN yarn install
RUN yarn test

FROM app-base AS app-zip-creator
COPY --from=test /app/package.json /app/yarn/lock ./
COPY app/spec ./spec
COPY app/src ./src
RUN apk add zip && \
   zip  -r /app.zip /app

FROM --platform=$BUILDPLATFORM  base AS dev
CMD ["mkdocs","serve","-a","0.0.0.0:8000"]

FROM --platform=$BUILDPLATFORM base AS build
COPY . .
RUN mkdocs build

FROM --platform=$TARGETPLATFORM nginx:apline
COPY --from=app-zip-creator /app.zip /usr/share/nginx/html/assets/app.zip
COPY --from=build /app/site /usr/share/nginx/html
