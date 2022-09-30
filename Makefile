.PHONY: help all fmt vet watch dev prod clean

help:
	@echo "Usage:\n \
	  make       - print this message\n \
	  make help  - print this message\n \
	  make all   - format and vet the source code then build executable\n \
	  make fmt   - format the source code\n \
	  make vet   - vet the source code\n \
	  make watch - watch for cganges and build development verion\n \
	  make dev   - build development verion of executable\n \
	  make prod  - build production verion of executable\n \
	  make clean - remove built executable\n \
	"

all: fmt vet prod

fmt:
	@v fmt -diff .
	@v fmt -w .

vet:
	@v vet -W .

watch:
	@[ -d dist ] || mkdir dist
	@fswatch -o -r src | xargs -n 1 -I {} sh -c \
	  'date +"%Y-%m-%d %H:%M:%S Build started" && \
	   v -skip-unused -o dist/portctl . && \
	   date +"%Y-%m-%d %H:%M:%S Build OK" || \
	   date +"%Y-%m-%d %H:%M:%S Build failed" && \
	   echo ----------------------------------------'

dev:
	@[ -d dist ] || mkdir dist
	@v -skip-unused -o dist/portctl . && echo 'Build OK'

prod:
	@[ -d dist ] || mkdir dist
	@v -prod -skip-unused -o dist/portctl . && echo 'Build OK'

clean:
	@[ -f dist/portctl ] && rm dist/portctl
