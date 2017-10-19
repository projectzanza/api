FROM ruby:2.4-alpine

ENV BUILD_DEPENDENCIES build-base ruby-dev openssl-dev postgresql-dev libc-dev linux-headers tzdata
ENV RUN_DEPENDENCIES bash postgresql file
ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY ./src/Gemfile .
COPY ./src/Gemfile.lock .

RUN apk add --update \
    --no-cache \
    --virtual build-dependencies \
    $BUILD_DEPENDENCIES && \
    gem install bundler && \
    bundle install && \
    apk del build-dependencies

RUN apk add --update \
    --no-cache \
    $RUN_DEPENDENCIES

COPY ./scripts/container /usr/local/bin
COPY ./src .

EXPOSE 3000
CMD /usr/local/bin/startup-dev.sh
