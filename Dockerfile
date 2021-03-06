FROM alpine:3.14

RUN apk add --update \
    tini \
    curl \
    jq \
    gettext \
    && rm -rf /var/cache/apk/*

ENV REQUESTS_JSON="[]"
ENV REQUESTS_INTERVAL="5"
ENV REQUESTS_SELECTION="random"

COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/curl_requests.sh /curl_requests.sh

RUN chmod a+x ./entrypoint.sh ./curl_requests.sh

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]