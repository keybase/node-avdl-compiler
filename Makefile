
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
	go get -t -v ./...

test: build-stamp
	npm run test:unit
	cd test && ../$(ICED) ./run.iced && cd files/ && go test $(CI_TAGS)

.PHONY: test
