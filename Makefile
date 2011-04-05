# Makefile for osprep
# $Id$

DESTDIR=
prefix=/usr/local
BINDIR=$(DESTDIR)$(prefix)/share/osprep
datadir=$(BINDIR)/reports
INSTALL=

WEBROOT=$(DESTDIR)/var/www
LINKTO=$(WEBROOT)/osprep

install: installdirs
	cp -pr * $(BINDIR)
	rm -f $(BINDIR)/Makefile
	if [ ! -e $(LINKTO) ]; then ln -s $(datadir) $(LINKTO); fi

installdirs:
	mkdir -p $(BINDIR)
	if [ ! -e $(WEBROOT) ]; then mkdir -p $(WEBROOT); fi

uninstall:
	linkstat=`readlink $(LINKTO)`
	if [ "$linkstat" = "$(datadir)" ]; then rm -f $(LINKTO); fi
	rm -rf $(BINDIR)

