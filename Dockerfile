# multi-stage builds require: Docker v17.05+

FROM wuyumin/go:dev AS buildStage

ARG GOPROXY_VERSION=2c027c9

RUN apk update && apk upgrade \
  && apk add git \
  && git clone https://github.com/goproxyio/goproxy.git goproxy \
  && cd goproxy \
  && git reset --hard ${GOPROXY_VERSION} \
  && go generate \
  && CGO_ENABLED=0 go build -ldflags="-s -w" -o goproxy \
  && upx goproxy





FROM wuyumin/go

LABEL maintainer="Yumin Wu"

COPY --from=buildStage /GoPath/src/goproxy/goproxy /usr/bin/goproxy

RUN mkdir -p /data/pkg/mod/cache/download \
  && wget https://raw.githubusercontent.com/thisdocker/goproxy/master/default/index.html -O /data/pkg/mod/cache/download/index.html \
  && wget https://raw.githubusercontent.com/thisdocker/goproxy/master/default/favicon.ico -O /data/pkg/mod/cache/download/favicon.ico \
  && apk update && apk upgrade \
  && apk add git mercurial subversion bzr fossil \
  && rm -rf /var/cache/apk/* /tmp/*

EXPOSE 80

CMD ["/usr/bin/goproxy", "-listen=0.0.0.0:80", "-cacheDir=/data"]
