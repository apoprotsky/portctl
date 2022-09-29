FROM thevlang/vlang:alpine AS builder
COPY . /home/portctl
RUN cd /home/portctl && v -prod -skip-unused .

FROM alpine:latest
COPY --from=builder /home/portctl/portctl /usr/local/bin
CMD ["portctl"]
