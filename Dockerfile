FROM ruby:alpine3.11
WORKDIR /app

# hadolint ignore=DL3018
RUN apk add --no-cache --virtual build-dependencies build-base git

COPY src/Gemfile ./
COPY src/commitlint.rb ./
RUN bundle install

ENTRYPOINT ["ruby", "/app/commitlint.rb"]
