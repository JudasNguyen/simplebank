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

# Copy the necessary files from the builder stage
COPY --from=builder /app/main .
COPY --from=builder /app/migrate ./migrate
COPY app.env .
COPY wait-for.sh .
COPY start.sh .
COPY db/migration ./migration

EXPOSE 8080
CMD [ "/app/main" ]
ENTRYPOINT [ "/app/start.sh" ]