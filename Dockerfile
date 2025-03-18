FROM --platform=${BUILDPLATFORM} golang:alpine AS builder

RUN apk add --no-cache make git ca-certificates

WORKDIR /workdir

ARG TARGETOS TARGETARCH TARGETVARIANT

RUN go env -w GO111MODULE=on
RUN go env -w GOPROXY=https://goproxy.cn,direct

RUN --mount=target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make BINDIR= ${TARGETOS}-${TARGETARCH}${TARGETVARIANT} && \
    mv /clash* /clash

FROM alpine:latest
LABEL org.opencontainers.image.source="https://github.com/Dreamacro/clash"

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /clash /

COPY Country.mmdb /root/.config/clash/
COPY config.yaml /root/.config/clash/

EXPOSE 7890 9090

ENTRYPOINT ["/clash"]
