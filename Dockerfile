FROM golang:1.21-alpine AS builder

WORKDIR /app

# Копируем файлы с зависимостями
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код
COPY main.go parcel.go parcel_test.go ./
COPY tracker.db ./

# Собираем приложение
RUN go build -o tracker-app .

# Финальный образ
FROM alpine:latest

RUN apk --no-cache add ca-certificates sqlite

WORKDIR /root/

# Копируем бинарный файл и БД из builder
COPY --from=builder /app/tracker-app .
COPY --from=builder /app/tracker.db .

# Запускаем приложение
CMD ["./tracker-app"]
