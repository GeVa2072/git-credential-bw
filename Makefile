PREFIX  ?= /usr/local
DESTDIR ?=
BINDIR  := $(DESTDIR)$(PREFIX)/bin
SRC     := git-credential-bw
DEST    := $(BINDIR)/$(SRC)

.PHONY: all install clean

all: clean install 

install: $(SRC)
	sudo install -d $(BINDIR)
	sudo install -m 0755 $(SRC) $(DEST)
	@echo "Installed $(SRC) -> $(DEST)"

clean:
	sudo rm -f $(DEST)
	@echo "Removed $(DEST)"
