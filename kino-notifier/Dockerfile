FROM ruby:2.2.4

ENV BUNDLE_SILENCE_ROOT_WARNING=true
RUN gem install bundler

RUN mkdir /app

ADD Gemfile /app/
ADD kino-notifier.gemspec /app/
ADD lib/kino/notifier/version.rb /app/lib/kino/notifier/version.rb

WORKDIR /app

RUN bundle install

ADD . .

VOLUME /app
