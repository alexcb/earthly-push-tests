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

b:
    FROM +a
    SAVE IMAGE --push $img
EOF

earthly +b
docker run --rm "$img" /bin/sh -c 'test -f /my-file'
docker run --rm "$img" /bin/sh -c '! test -f /my-file-push'

earthly --push +b
docker run --rm "$img" /bin/sh -c 'test -f /my-file'
docker run --rm "$img" /bin/sh -c '! test -f /my-file-push'

# NOTE: similar to the previous test, but now with a SAVE IMAGE --push
# the `RUN --push` command is never saved to the image, as `RUN --push` is performed *AFTER* SAVE IMAGES are done.
