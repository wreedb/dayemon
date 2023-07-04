default:
  nimble build

run:
  nim c -r main.nim

make:
  nim cc \
  --out:dayemon \
  --outdir:build \
  --os:linux \
  --cpu:amd64 \
  --opt:speed \
  --mm:orc \
  -d:release \
  main.nim

install:
  cp build/dayemon /usr/bin/dayemon
