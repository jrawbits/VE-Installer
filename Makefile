# Shortcut Makefile so you can do the basics without changing
# into the 'build' directory

.PHONY: all repository binary installers

all:
	$(MAKE) -C "build" all

repository:
	$(MAKE) -C "build" repository

binary:
	$(MAKE) -C "build" binary

installers:
	$(MAKE) -C "build" installers
