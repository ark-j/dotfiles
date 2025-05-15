KIND_VERSION=$(curl -sX GET https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep '"tag_name":' | awk '{gsub(/[",]/, "", $2); print $2}')
SYSTEM_NAME=$(uname | awk '{print tolower($0)}')
SYSTEM_ARCH=$(uname -m)
if [ "$SYSTEM_ARCH" == "x86_64" ]; then
    SYSTEM_ARCH="amd64"
fi
if [ -n "$KIND_VERSION" ]; then
    curl -Lo /tmp/kind "https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-${SYSTEM_NAME}-${SYSTEM_ARCH}"
    chmod +x /tmp/kind
    sudo mv /tmp/kind /usr/local/bin
    echo "--------------------------------------------------------------------"
    echo "installed kind version ${KIND_VERSION}-${SYSTEM_NAME}-${SYSTEM_ARCH}"
fi
