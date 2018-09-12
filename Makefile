.POSIX:
.SUFFIXES:

all: routes.js simple.js

routes.js: examples/Routes.idr WebServer/Server.idr
	idris --output $@ --codegen node $<

simple.js: examples/Simple.idr WebServer/Server.idr
	idris --output $@ --codegen node $<
