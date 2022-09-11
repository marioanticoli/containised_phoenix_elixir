ARG MIX_ENV="prod"
ARG PROJECT_NAME="cabify"

# Extend from the official Elixir image
FROM hexpm/elixir:1.14.0-erlang-23.3.4.17-alpine-3.15.6 AS build

# install build dependencies
RUN apk add --no-cache build-base git python3 curl

# sets work dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

# install mix dependencies
COPY ${PROJECT_NAME}/mix.exs ${PROJECT_NAME}/mix.lock ./
RUN mix deps.get --only $MIX_ENV

# copy compile configuration files
RUN mkdir config
COPY ${PROJECT_NAME}/config/config.exs ${PROJECT_NAME}/config/$MIX_ENV.exs config/

# compile dependencies
RUN mix deps.compile

# compile project
COPY ${PROJECT_NAME}/lib lib
RUN mix compile

# copy runtime configuration file
COPY ${PROJECT_NAME}/config/runtime.exs config/

# assemble release
RUN mix release

FROM alpine:3.15.6 AS app

ARG MIX_ENV

# install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses-libs ca-certificates libc6-compat
ENV USER="elixir"

WORKDIR "/home/${USER}/app"

# Create  unprivileged user to run the release
RUN \
  addgroup \
   -g 1000 \
   -S "${USER}" \
  && adduser \
   -s /bin/sh \
   -u 1000 \
   -G "${USER}" \
   -h "/home/${USER}" \
   -D "${USER}" \
  && su "${USER}"

# run as user
USER "${USER}"

# copy release executables
COPY --from=build --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/${PROJECT_NAME} ./

EXPOSE 9091

ENTRYPOINT ["bin/${PROJECT_NAME}"]

CMD ["start"]