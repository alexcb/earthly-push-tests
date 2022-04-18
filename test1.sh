#!/bin/sh
set -ex
USER="alexcb132"

# Test 1: basic RUN + SAVE IMAGE

path="/tmp/run-push-save-push/test1"
rm -rf "$path" || true
mkdir -p "$path"
cd "$path"

img="$USER/testimg:$(uuidgen)"
echo "img=$img"

cat > Earthfile <<EOF
VERSION 0.6
a:
    FROM alpine
    RUN touch /my-file
    SAVE IMAGE $img
EOF

earthly +a

docker run --rm "$img" /bin/sh -c 'ls -la /my-file'

earthly --push +a
if docker pull "$img" 2>/dev/null; then
    echo "ERROR: $img was pushed to dockerhub" # fortunately this doesn't happen
    exit 1
fi
