.POSIX:
.SUFFIXES:

simple.js: examples/Simple.idr WebServer/Server.idr
	idris --output $@ --codegen node $<
