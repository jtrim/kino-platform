FROM ruby:2.2.4

RUN gem install bundler

RUN mkdir /app
WORKDIR /app

ADD Gemfile .
ADD Gemfile.lock .
ADD kino-notifier.gemspec .
ADD lib/kino/notifier/version.rb lib/kino/notifier/version.rb

RUN bundle install

ADD . .
