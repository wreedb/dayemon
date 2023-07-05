set dotenv-load

prefix := '/usr/local'

default: make

getarch:
  @if  [ "{{arch()}}" = "x86_64"  ]; then echo "D_ARCH=amd64" > .env; \
  elif [ "{{arch()}}" = "aarch64" ]; then echo "D_ARCH=arm64" > .env; \
  else echo "Dayemon does not work with your cpu architecture, sorry!" fi

build:
  @echo "compiling for: $D_ARCH"
  nim cc --hints:off --forceBuild:on --out:dayemon --outdir:_build --os:linux --cpu:$D_ARCH --opt:speed --mm:orc -d:release src/main.nim

make: getarch build strip

clean:
  -rm -rf _build/
  -rm .env

strip:
  [ -f "_build/dayemon" ] && strip _build/dayemon

compress:
  [ -f "_build/dayemon" ] && upx -qqq --exact --best _build/dayemon

install:
  install -Dm 755 _build/dayemon {{prefix}}/bin/dayemon
  mkdir -p {{prefix}}/share/doc/dayemon
  cp ./doc/example_init.yaml {{prefix}}/share/doc/dayemon
