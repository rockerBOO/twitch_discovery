#===========
#Build Stage
#===========
FROM bitwalker/alpine-elixir:1.5 as build

#Copy the source folder into the Docker image
COPY rel ./rel
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY web ./web
COPY package.json .
COPY package-lock.json .
COPY brunch-config.js .
COPY mix.exs .
COPY mix.lock .

#Install dependencies and build Release

ENV MIX_ENV=prod
RUN apk update && \
    apk add -u musl musl-dev musl-utils nodejs-npm build-base
RUN mix deps.get
RUN mix compile
RUN npm install && \
    ./node_modules/.bin/brunch b -p && \
    mix phx.digest
RUN mix release

#Extract Release archive to /rel for copying in next stage
RUN APP_NAME="twitch_discovery" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

#================
#Deployment Stage
#================
FROM pentacent/alpine-erlang-base:latest

#Set environment variables and expose port
EXPOSE 4000
ENV REPLACE_OS_VARS=true \
    PORT=4000

#Copy and extract .tar.gz Release file from the previous stage
COPY --from=build /export/ .

#Change user
# USER default

#Set default entrypoint and command
ENTRYPOINT ["/opt/app/bin/twitch_discovery"]
CMD ["console"]
