FROM golang:1.15.2-alpine3.12 AS builder
LABEL maintainer="tiger <codework9527@gmail.com>"

ENV GOPROXY "https://goproxy.cn,direct"
RUN apk add --no-cache g++

WORKDIR /app
COPY ./go-socks5 /app/
RUN CGO_ENABLED=1 GO111MODULE=on GOOS=linux go build -o socks5 main.go

FROM amd64/alpine:3.10
ENV FRP_VERSION 0.35.1
RUN cd /root \
    &&  wget --no-check-certificate -c https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz \
    &&  tar zxvf frp_${FRP_VERSION}_linux_amd64.tar.gz  \
    &&  cd frp_${FRP_VERSION}_linux_amd64/ \
    &&  cp frpc /usr/bin/ \
    &&  mkdir -p /etc/frp \
    &&  cp frpc.ini /etc/frp \
    &&  cd /root \
    &&  rm frp_${FRP_VERSION}_linux_amd64.tar.gz \
    &&  rm -rf frp_${FRP_VERSION}_linux_amd64/ 

WORKDIR /app
COPY --from=builder /app/socks5 /app/socks5
ADD start.sh /etc/

ENTRYPOINT '/etc/start.sh'