# Multi-stage Dockerfile for the Go HTTP server
FROM golang:1.20-alpine AS builder

WORKDIR /app
# Cache dependencies    
COPY go.mod go.sum ./
RUN go mod download

# Copy source and build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server .

FROM alpine:3.18
RUN apk add --no-cache ca-certificates
WORKDIR /
COPY --from=builder /app/server /server
EXPOSE 8080
ENTRYPOINT ["/server"]

# Docker-level healthcheck used by docker and docker-compose
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
	CMD curl -fsS http://localhost:8080/health || exit 1
