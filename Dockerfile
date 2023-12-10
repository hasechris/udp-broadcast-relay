FROM scratch

COPY --chmod=755 udp-broadcast-relay /udp-broadcast-relay

ENTRYPOINT ["/udp-broadcast-relay"]