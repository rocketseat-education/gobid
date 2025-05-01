FROM golang:1.22.2-alpine as builder

WORKDIR /app

RUN go install github.com/jackc/tern@latest

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/api

FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache postgresql bash

COPY --from=builder /app/main .
COPY --from=builder /app/.env .
COPY --from=builder /go/bin/tern /usr/local/bin/tern
COPY --from=builder /app/internal/store/pgstore/migrations /app/internal/store/pgstore/migrations

RUN mkdir -p /app/scripts
COPY scripts/init.sh /app/scripts/init.sh
RUN chmod +x /app/scripts/init.sh

EXPOSE 3080

CMD ["/app/scripts/init.sh"]
