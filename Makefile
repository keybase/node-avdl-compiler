
ICED=./node_modules/.bin/iced

default: build-stamp

lib/%.js: src/%.iced
	$(ICED) -I node -c -o `dirname $@` $<

build-stamp: \
	lib/main.js \
	lib/emit.js
	date > $@

test:
	(cd test && iced ./run.iced && cd files/ && cp sample.go-nocompile sample.go && (go build ; rm sample.go ) )

.PHONY: test
