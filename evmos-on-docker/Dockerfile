FROM golang:stretch AS build-env

WORKDIR /go/src/github.com/tharsis/evmos

RUN apt-get update -y
RUN apt-get install git -y

COPY ./EVMOS-source-code .

RUN make build

FROM golang:stretch

COPY --from=build-env /go/src/github.com/tharsis/evmos/build/evmosd /usr/bin/evmosd

RUN apt-get update -y
RUN apt-get install ca-certificates jq -y

WORKDIR /evmos_home

COPY ./.evmosdn0 .
COPY ./.evmosdn1 .
COPY ./.evmosdn2 .

WORKDIR /root

EXPOSE 26656 26657 1317 9090 8545

ENTRYPOINT /usr/bin/evmosd start --home "/evmos_home/.evmosdn$NODE"
