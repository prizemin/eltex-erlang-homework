# Build stage 0
FROM erlang:21-alpine

# Set working directory
RUN mkdir /buildroot
WORKDIR /buildroot

# Add git for nksip
RUN apk add --no-cache git build-base

# Copy webRtp application
COPY . webRtp

# And build the release
WORKDIR webRtp

RUN rebar3 as prod release

# Build stage 1
FROM alpine:3.13

# Install some libs
RUN apk add git && \
    apk add make gcc musl-dev && \
    apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs && \
    apk add --no-cache libstdc++ && \
    apk add --no-cache ffmpeg && \
    apk add --no-cache ortp-dev && \
    apk add --no-cache bctoolbox-dev

# Copy the required priv files from the local project
COPY --from=0 /buildroot/webRtp/apps/webRtp/priv /webRtp/priv/
# Copy the required c_src files from the local project
COPY --from=0 /buildroot/webRtp/c_src /webRtp/c_src

COPY --from=0 /buildroot/webRtp/_build/prod/rel/webRtp /webRtp

# Compile rtpsend.c
RUN make -C /webRtp/c_src
# Expose relevant ports
EXPOSE 8080

# The command to launch the application in the interactive console mode
CMD ["/webRtp/bin/webRtp", "foreground"]