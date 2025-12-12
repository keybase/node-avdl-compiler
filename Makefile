
ICED=./node_modules/.bin/iced

default: build-stamp

lib/%.js: src/%.iced
	$(ICED) -I node -c -o `dirname $@` $<

build-stamp: \
	lib/main.js \
	lib/py_emit.js \
	lib/ts_emit.js \
	lib/go_emit.js \
	lib/base_emitter.js \
	lib/utils.js
	date > $@

install:
	npm install --ignore-scripts
	cd test/files && go mod download && go mod tidy

test: build-stamp
	npm run test:unit
	cd test && ../$(ICED) ./run.iced && cd files/ && go test $(CI_TAGS)

.PHONY: test
