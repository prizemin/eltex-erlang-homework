# Build stage 0
FROM erlang:21-alpine

# Set working directory
RUN mkdir /buildroot
WORKDIR /buildroot

# Add git for nksi
RUN apk add --no-cache git build-base

# Copy our Erlang test application
COPY . webRtp

# And build the release
WORKDIR webRtp

RUN rebar3 as prod release

# Build stage 1
FROM alpine:3.13

# Install some libs
RUN apk add git && \
    apk add --no-cache make gcc musl-dev && \
    apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs && \
    apk add --no-cache libstdc++ && \
    apk add --no-cache ffmpeg && \
    apk add --no-cache ortp-dev && \
    apk add --no-cache bctoolbox-dev

COPY --from=0 /buildroot/webRtp/apps/webRtp/priv /webRtp/priv/

COPY --from=0 /buildroot/webRtp/c_src /webRtp/c_src

COPY --from=0 /buildroot/webRtp/_build/prod/rel/webRtp /webRtp

RUN make -C /webRtp/c_src
# Expose relevant ports
EXPOSE 8443

# The command to launch the application in the interactive console mode
CMD ["/webRtp/bin/webRtp", "foreground"]