podman build -t user:latest .
podman run --rm -it --name totality_corp -p 50051:50051/tcp user:latest