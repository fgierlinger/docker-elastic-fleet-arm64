FROM centos:latest as builder

RUN dnf -y update && \
    dnf -y install git make perl-Digest-SHA golang

RUN git clone https://github.com/elastic/fleet-server
RUN cd fleet-server && LANGUAGE=C LC_ALL=C PLATFORMS=linux/arm64 make release

FROM centos:8

RUN mkdir -p /fleet-server/
COPY --from=builder /fleet-server/build/binaries/fleet-server-8.0.0-linux-arm64/fleet-server /fleet-server/fleet-server
COPY --from=builder /fleet-server/fleet-server.yml /fleet-server/fleet-server.yml

CMD ["/fleet-server/fleet-server", "--config", "/fleet-server/fleet-server.yml"]