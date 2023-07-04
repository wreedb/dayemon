default:
  echo "Run just make or just make_arm64"

make:
  nim cc \
  --forceBuild:on \
  --out:dayemon \
  --outdir:build \
  --os:linux \
  --cpu:amd64 \
  --opt:speed \
  --mm:orc \
  -d:release \
  main.nim


make_arm64:
  nim cc \
  --forceBuild:on \
  --out:dayemon \
  --outdir:build \
  --os:linux \
  --cpu:arm64 \
  --opt:speed \
  --mm:orc \
  -d:release \
  main.nim

clean:
  rm -rf build/

install:
  cp build/dayemon /usr/bin/dayemon
