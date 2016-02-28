
ICED=./node_modules/.bin/iced

default: build-stamp

lib/%.js: src/%.iced
	$(ICED) -I node -c -o `dirname $@` $<

build-stamp: \
	lib/main.js
	date > $@

test:
	(cd test && iced ./run.iced)

.PHONY: test
