FROM golang:1.12-alpine as builder
LABEL maintainer="tiger <codework9527@gmail.com>"

WORKDIR /go/src/github.com/olebedev/socks5
COPY ./socks5 .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-s' -o ./socks5

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
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/src/github.com/olebedev/socks5/socks5 /app
ADD start.sh /etc/
RUN chmod 777 /etc/start.sh
RUN chmod 777 /app/socks5

ENTRYPOINT '/etc/start.sh'