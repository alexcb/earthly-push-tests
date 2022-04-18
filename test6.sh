#!/bin/sh
set -ex
USER="alexcb132"

path="/tmp/run-push-save-push/test2"
rm -rf "$path" || true
mkdir -p "$path"
cd "$path"

img="$USER/testimg:$(uuidgen)"
echo "img=$img"

cat > Earthfile <<EOF
VERSION 0.6
a:
    FROM alpine
    WORKDIR /data
    RUN echo a > my-file
    RUN --push echo b > my-file-push   # allowing RUN --push before SAVE ARTIFACT is confusing.
    SAVE ARTIFACT *

b:
    FROM alpine
    WORKDIR /the-data
    COPY +a/* .
    RUN test -f my-file
    RUN --push ! test -f my-file-push # my-file-push will never get copied over (because COPY is evaluated in the first stage)
EOF

earthly +b
earthly --push +b
