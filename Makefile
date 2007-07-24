# Makefile for osprep
# $Id$

DESTDIR=
prefix=/usr/local
BINDIR=$(DESTDIR)$(prefix)/osprep
INSTALL=

install: installdirs
	cp -pr * $(BINDIR)
	rm -f $(BINDIR)/Makefile

installdirs:
	mkdir -p $(BINDIR)

uninstall:
	rm -rf $(BINDIR)

