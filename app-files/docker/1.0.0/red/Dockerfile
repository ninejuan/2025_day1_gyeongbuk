FROM alpine:latest

WORKDIR /app

COPY red_1.0.0 /app/red_1.0.0

RUN apk add --no-cache ca-certificates tzdata && \
    chmod +x /app/red_1.0.0

EXPOSE 8080

ENTRYPOINT ["/app/red_1.0.0"]
