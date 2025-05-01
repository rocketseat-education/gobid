FROM golang:1.22.2-alpine

WORKDIR /app

RUN go install github.com/jackc/tern@latest

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/api
