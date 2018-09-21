.POSIX:
.SUFFIXES:

all: examples/Routes.min.js examples/Simple.min.js
dev: examples/Routes.js examples/Simple.js
clean:
	rm -f examples/*.js
	rm -f examples/*.ibc
	rm -f WebServer/*.ibc

.SUFFIXES: .js .min.js .idr
.idr.js:
	idris \
		--package contrib \
		--output $@ \
		--codegen node $<

.js.min.js:
	npx google-closure-compiler < $< > $@

examples/*.js: WebServer/*.idr
