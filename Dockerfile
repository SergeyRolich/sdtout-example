FROM golang:1.16.10 as builder

ARG BENTHOS_VERSION
ENV BENTHOS_VERSION ${BENTHOS_VERSION:-3.58.0}

RUN useradd -u 10001 benthos

WORKDIR /go/src/github.com/Jeffail/benthos/

RUN wget -qO- https://github.com/Jeffail/benthos/archive/v${BENTHOS_VERSION}.tar.gz | tar xvz -C /tmp
RUN cp -R /tmp/benthos-${BENTHOS_VERSION}/* /go/src/github.com/Jeffail/benthos/
RUN cd /go/src/github.com/Jeffail/benthos/

ENV GO111MODULE on
RUN go mod vendor
RUN CGO_ENABLED=0 GOOS=linux VERSION=${BENTHOS_VERSION} GOFLAGS=-mod=vendor make

WORKDIR /go/src/github.com/sergeyrolich/sdtout-example

COPY . .

RUN CGO_ENABLED=0 make build

FROM busybox@sha256:a9286defaba7b3a519d585ba0e37d0b2cbee74ebfe590960b0b1d6a5e97d1e1d

WORKDIR /app/
ENV TZ=UTC

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd

USER benthos

COPY --chown=benthos:10001 --from=builder /go/src/github.com/Jeffail/benthos/target/bin/benthos .
COPY --chown=benthos:10001 --from=builder /go/src/github.com/sergeyrolich/sdtout-example/stdout-app .
COPY --chown=benthos:10001 configs /app/configs

VOLUME /tmp

ENTRYPOINT ["./benthos", "-r", "./configs/resources.yaml", "-c", "./configs/pipeline.yaml", "--log.level", "info"]
