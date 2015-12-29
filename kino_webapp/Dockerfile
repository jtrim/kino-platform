FROM trenpixster/elixir

RUN apt-get update && apt-get install -y \
  nodejs \
  npm \
  postgresql-client

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

ADD . .

EXPOSE 4002 4003
VOLUME /app
CMD ["mix", "phoenix.server"]
