FROM golang:1.16.10 as builder

WORKDIR /go/src/github.com/sergeyrolich/sdtout-example

COPY . .

RUN CGO_ENABLED=0 make build

FROM jeffail/benthos:3.59.0-rc2@sha256:aa44f0c7cc3235107688c73298823a27919cee68777ff6150980ae49931dae71

ENV TZ=UTC
USER benthos

COPY --chown=benthos:10001 --from=builder /go/src/github.com/sergeyrolich/sdtout-example/stdout-app .
COPY --chown=benthos:10001 configs configs

VOLUME /tmp

ENTRYPOINT ["./benthos", "-r", "./configs/resources.yaml", "-c", "./configs/pipeline.yaml", "--log.level", "info"]
