# build stage
FROM golang:alpine AS build
LABEL stage="build"
WORKDIR /src
COPY . .
ENV PATH="$PATH:$(go env GOPATH)/bin"
RUN apk add --no-cache protobuf
RUN go mod download
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
RUN protoc userpb/user.proto --go_out=. --go-grpc_out=.
RUN go build -o user-bin main.go

# release stage
FROM alpine:latest AS final
LABEL stage="final"
WORKDIR /app
COPY --from=build /src/user-bin .
EXPOSE 50051
ENTRYPOINT [ "/app/user-bin", "startserver" ]