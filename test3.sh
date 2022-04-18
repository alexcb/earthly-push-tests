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
    SAVE IMAGE $img
EOF

earthly +b
docker run --rm "$img" /bin/sh -c 'test -f /my-file'
docker run --rm "$img" /bin/sh -c '! test -f /my-file-push'

earthly --push +b
docker run --rm "$img" /bin/sh -c 'test -f /my-file'
docker run --rm "$img" /bin/sh -c '! test -f /my-file-push' # NOTE this still doesn't exist, as it is run AFTER the SAVE IMAGE is done

# NOTE: this test is very similar to test2.sh; however just moves the SAVE IMAGE to a different target.
# however the previous test fails to export the img locally in both the regular, and push cases.
# I would have expected this to fail in both cases since we have a `RUN --push` followed by a non-push command.

if docker pull "$img" 2>/dev/null; then
    echo "ERROR: $img was pushed to dockerhub" # fortunately this doesn't happen
    exit 1
fi

echo done
