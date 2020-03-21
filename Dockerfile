FROM --platform=$BUILDPLATFORM golang:1.14-alpine AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG version="9.0.0"


WORKDIR /opt

RUN apk add -U git
RUN git clone https://github.com/keycloak/keycloak-gatekeeper.git
WORKDIR /opt/keycloak-gatekeeper

RUN GOOS=$(echo $TARGETPLATFORM | cut -f1 -d/) && \
    GOARCH=$(echo $TARGETPLATFORM | cut -f2 -d/) && \
    GOARM=$(echo $TARGETPLATFORM | cut -f3 -d/ | sed "s/v//" ) && \
    CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} GOARM=${GOARM} go build -ldflags="-X main.gitsha=$(git --no-pager describe --always --dirty) -X main.compiled=$(date '+%s')" -o keycloak-gatekeeper




FROM gcr.io/distroless/static

COPY --from=builder /opt/keycloak-gatekeeper/keycloak-gatekeeper /bin/keycloak-gatekeeper

USER 1234

ENTRYPOINT ["/bin/keycloak-gatekeeper"]
