FROM centos:latest as builder

ARG FLEET_SERVER_VERSION=7.13.0

RUN dnf -y update && \
    dnf -y install git make perl-Digest-SHA golang

RUN git clone --branch v${FLEET_SERVER_VERSION} https://github.com/elastic/fleet-server
RUN cd fleet-server && LANGUAGE=C LC_ALL=C PLATFORMS=linux/arm64 make release
RUN ln -s /fleet-server/build/binaries/fleet-server-${FLEET_SERVER_VERSION}-linux-arm64/ /fleet-server/build/binaries/fleet-server

FROM centos:8

RUN mkdir -p /fleet-server/
COPY --from=builder /fleet-server/build/binaries/fleet-server/fleet-server /fleet-server/fleet-server
COPY --from=builder /fleet-server/fleet-server.yml /fleet-server/fleet-server.yml

CMD ["/fleet-server/fleet-server", "--config", "/fleet-server/fleet-server.yml"]