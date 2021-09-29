FROM golang:1.17.1-alpine3.14 as builder

RUN apk add --update ca-certificates git

ENV SRC github.com/noho-digital/segment-proxy
ENV CGO_ENABLED=0
ENV GO111MODULE=on
ENV GOOS=linux
ENV GOARCH=amd64

ARG VERSION

COPY . /go/src/${SRC}
WORKDIR /go/src/${SRC}

RUN go build -a -installsuffix cgo -ldflags "-w -s -extldflags '-static' -X main.version=$VERSION" -o /proxy

FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /proxy /proxy

EXPOSE 8080

ENTRYPOINT ["/proxy"]