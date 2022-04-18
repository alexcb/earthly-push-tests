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
    RUN touch /my-file
    RUN --push touch /my-file-push
    SAVE IMAGE --push $img
EOF

earthly +a
docker run --rm "$img" /bin/sh -c "echo this fails, as $img was never exported" || echo "*******ERROR docker run failed"

earthly --push +a
docker run --rm "$img" /bin/sh -c 'test -f /my-file'
docker run --rm "$img" /bin/sh -c 'test -f /my-file-push' # NOTE: this file does exist; however in the previous test which was split in two targets, it didnt exist
echo done
