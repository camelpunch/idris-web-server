.POSIX:
.SUFFIXES:

all: examples/Routes.min.js examples/Simple.min.js
dev: examples/Routes.js examples/Simple.js
clean:
	rm examples/*.js
	rm examples/*.ibc
	rm WebServer/*.ibc

.SUFFIXES: .js .min.js .idr
.idr.js:
	idris \
		--package contrib \
		--output $@ \
		--codegen node $<

.js.min.js:
	npx google-closure-compiler < $< > $@

examples/*.js: WebServer/*.idr
