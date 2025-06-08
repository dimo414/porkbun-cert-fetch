FROM alpine:latest

RUN apk --update add \
  bash \
  ca-certificates \
  coreutils \
  curl \
  jq \
  openssl

COPY --chmod=744 porkbun-cert-fetch /
ENTRYPOINT [ "/porkbun-cert-fetch" ]

LABEL \
  org.opencontainers.image.source=https://github.com/dimo414/porkbun-cert-fetch \
  org.opencontainers.image.description="Utility to fetch wildcard SSL certificates from Porkbun" \
  org.opencontainers.image.licenses=MIT