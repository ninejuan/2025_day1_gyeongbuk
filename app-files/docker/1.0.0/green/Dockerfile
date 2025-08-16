FROM alpine:latest

WORKDIR /app

COPY green_1.0.0 /app/green_1.0.0

RUN apk add --no-cache ca-certificates tzdata && \
    chmod +x /app/green_1.0.0

EXPOSE 8080

ENTRYPOINT ["/app/green_1.0.0"]
