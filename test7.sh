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
    RUN --push echo b > my-file-push
    SAVE ARTIFACT * AS LOCAL out/
EOF

earthly +a
# earthly displays "Did not execute push command RUN --push echo b > my-file-push"
# and never outputs out/my-file
test -f out/my-file || (echo "out/my-file doesnt exist")

# Then when you run this:
earthly --push +a

# buildkitd crashes.

#################
# FROM:   docker logs earthly-buildkitd
#################

#panic: runtime error: invalid memory address or nil pointer dereference
#[signal SIGSEGV: segmentation violation code=0x1 addr=0x70 pc=0xc25889]
#
#goroutine 15698 [running]:
#github.com/moby/buildkit/solver.(*Job).walkBuildInfo(0xc00073bb80, {0x1663b00, 0xc000fdfe40}, {0x47, {0x166c5b8, 0xc0013f2280}}, 0xc000359380)
#	/src/solver/jobs.go:524 +0x169
#github.com/moby/buildkit/solver.(*Job).walkBuildInfo(0xc00073bb80, {0x1663b00, 0xc000fdfe40}, {0x0, {0x166c5b8, 0xc0013f22c0}}, 0xc000359380)
#	/src/solver/jobs.go:532 +0x1dc
#github.com/moby/buildkit/solver.(*Job).Build(0xc00073bb80, {0x1663b00, 0xc000fdfe40}, {0x0, {0x166c638, 0xc000446400}})
#	/src/solver/jobs.go:517 +0x3af
#github.com/moby/buildkit/solver/llbsolver.(*llbBridge).loadResult(0xc000415310, {0x1663b00, 0xc000fdfe40}, 0x28, {0x0, 0x0, 0x46940e})
#	/src/solver/llbsolver/bridge.go:139 +0x3e3
#github.com/moby/buildkit/solver/llbsolver.newResultProxy.func1({0x1663b00, 0xc000fdfe40})
#	/src/solver/llbsolver/bridge.go:190 +0x65
#github.com/moby/buildkit/solver/llbsolver.(*resultProxy).Result.func2({0x1663b00, 0xc000fdfe40})
#	/src/solver/llbsolver/bridge.go:271 +0x150
#github.com/moby/buildkit/util/flightcontrol.(*call).run(0xc00164e6c0)
#	/src/util/flightcontrol/flightcontrol.go:121 +0x5e
#sync.(*Once).doSlow(0x0, 0x0)
#	/usr/local/go/src/sync/once.go:68 +0xd2
#sync.(*Once).Do(0x920406, 0xc00156d600)
#	/usr/local/go/src/sync/once.go:59 +0x1f
#created by github.com/moby/buildkit/util/flightcontrol.(*call).wait
#	/src/util/flightcontrol/flightcontrol.go:164 +0x44f
#time="2022-04-19T15:41:26Z" level=error msg="reading from connection failed: EOF" app=shellrepeater
#Error: buildkit process has exited
