#!/bin/sh
set -ex
USER="alexcb132"

# Test 2: RUN, RUN --push, SAVE IMAGE
# thie fails:

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
    RUN --push touch /my-file-with-push
    SAVE IMAGE $img
EOF

earthly +a

# This produces:
#  Did not execute push command RUN --push touch /my-file-with-push
#  Did not push image alexcb132/testimg:run-push-save-push as evaluating the image would have caused a RUN --push to execute
#
# BUG: this fails with: docker: Error response from daemon: manifest for alexcb132/testimg:2f6cbe0d-f71e-4b5e-adc9-a81e707f00e4 not found
# due to the RUN --push being propigated to the SAVE IMAGE command
docker run --rm "$img" /bin/sh -c 'ls -la /my-file' || (echo "***ERROR: docker run failed***")

# part b: run earthly with --push

earthly --push +a

# BUG: this still fails with: docker: Error response from daemon: manifest for alexcb132/testimg:2f6cbe0d-f71e-4b5e-adc9-a81e707f00e4 not found: manifest unknown: manifest unknown.
docker run --rm "$img" /bin/sh -c 'ls -la /my-file' || (echo "***ERROR: docker run failed again***")

if docker pull "$img" 2>/dev/null; then
    echo "ERROR: $img was pushed to dockerhub" # fortunately this doesn't happen
    exit 1
fi

# TODO: This Earthfile should be invalid, and return an error similar to "no non-push commands allowed after a --push"
