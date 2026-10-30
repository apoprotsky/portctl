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
	@cd src; v fmt -l .
	@cd src; v fmt -diff .
	@cd src; v fmt -w .

vet:
	@cd src; v vet -W .

watch:
	@[ -d dist ] || mkdir dist
	@cd src; \
	fswatch -o -r src | xargs -n 1 -I {} sh -c \
	  'date +"%Y-%m-%d %H:%M:%S Build started" && \
	   v -o ../dist/portctl . && \
	   date +"%Y-%m-%d %H:%M:%S Build OK" || \
	   date +"%Y-%m-%d %H:%M:%S Build failed" && \
	   echo ----------------------------------------'

dev:
	@[ -d dist ] || mkdir dist
	@cd src; \
	v -o ../dist/portctl . && echo 'Build OK'

prod:
	@[ -d dist ] || mkdir dist
	@cd src; \
	v -prod -o dist/portctl . && echo 'Build OK'

clean:
	@[ -f dist/portctl ] && rm dist/portctl
