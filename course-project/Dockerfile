# Build stage 0
FROM erlang:21-alpine

# Set working directory
RUN mkdir /buildroot
WORKDIR /buildroot

# Add git for nksip
RUN apk add --no-cache git build-base

# Copy our Erlang test application
COPY webRtp webRtp

# And build the release
WORKDIR webRtp

RUN rebar3 as prod release

# Build stage 1
FROM alpine:3.13

# Install some libs
RUN apk add git && \
    apk add --no-cache make && \
    apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs && \
    apk add --no-cache libstdc++

# Install the released application
COPY --from=0 /buildroot/webRtp/_build/prod/rel/webRtp /webRtp

# Expose relevant ports
# The command to launch the application in the interactive console mode
CMD ["/webRtp/bin/webRtp", "foreground"]
