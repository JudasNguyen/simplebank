# Build stage
FROM golang:1.23-alpine3.20 AS builder

WORKDIR /app
COPY . .

# Build the main Go application
RUN go build -o main main.go

# Install curl and download the migrate binary
RUN apk add --no-cache curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.18.1/migrate.linux-amd64.tar.gz | tar -xz -C /app

# Debugging step to list files and confirm migration binary exists
RUN ls -al /app

# Run stage
FROM alpine:3.20

WORKDIR /app

# Copy necessary files from the builder stage
COPY --from=builder /app/main .
COPY --from=builder /app/migrate ./migrate
COPY --from=builder /app/db/migration ./migration
COPY --from=builder /app/app.env .
COPY --from=builder /app/wait-for.sh .
COPY --from=builder /app/start.sh .

# Set executable permissions for the scripts
RUN chmod +x /app/start.sh /app/wait-for.sh

# Expose the port and set the entrypoint and command
EXPOSE 8080
ENTRYPOINT ["/app/start.sh"]
CMD ["/app/main"]