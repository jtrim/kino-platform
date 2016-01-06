FROM heroku/cedar:14

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /tmp

RUN echo "deb http://packages.erlang-solutions.com/ubuntu trusty contrib" >> /etc/apt/sources.list && \
  apt-key adv --fetch-keys http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc && \
  apt-get -qq update && apt-get install -y \
  esl-erlang \
  git \
  unzip \
  build-essential \
  nodejs \
  npm \
  postgresql-client \
  wget && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

WORKDIR /elixir
RUN wget -q https://github.com/elixir-lang/elixir/releases/download/v1.2.0/Precompiled.zip && \
    unzip Precompiled.zip && \
    rm -f Precompiled.zip && \
    ln -s /elixir/bin/elixirc /usr/local/bin/elixirc && \
    ln -s /elixir/bin/elixir /usr/local/bin/elixir && \
    ln -s /elixir/bin/mix /usr/local/bin/mix && \
    ln -s /elixir/bin/iex /usr/local/bin/iex

RUN /usr/local/bin/mix local.hex --force && \
    /usr/local/bin/mix local.rebar --force

# For phoenix code reload watches
RUN wget http://github.com/downloads/rvoicilas/inotify-tools/inotify-tools-3.14.tar.gz
RUN tar -xzf inotify-tools-3.14.tar.gz
RUN (cd inotify-tools-3.14 && ./configure --prefix=/usr && make && make install)

# Put node in the right spot
RUN ln -nsf $(which nodejs) $(dirname `which nodejs`)/node

RUN mkdir /app
ADD mix.exs /app/
ADD mix.lock /app/

WORKDIR /app
RUN mix deps.get

ADD ./priv/static/ /app/
RUN MIX_ENV=prod mix phoenix.digest

ADD . .

EXPOSE 4002 4003
VOLUME /app
CMD ["mix", "phoenix.server"]
