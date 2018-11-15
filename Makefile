
ICED=./node_modules/.bin/iced

default: build-stamp

lib/%.js: src/%.iced
	$(ICED) -I node -c -o `dirname $@` $<

build-stamp: \
	lib/main.js \
	lib/emit.js
	date > $@

install:
	npm install
	go get -d -t -v ./...

test: build-stamp
	(cd test && ../$(ICED) ./run.iced && cd files/ && cp sample.go-nocompile sample.go && (go test ; rm sample.go ) )

.PHONY: test
