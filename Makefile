PREFIX  ?= /usr/local
DESTDIR ?=
BINDIR  := $(DESTDIR)$(PREFIX)/bin
SRC     := git-credential-bw
DEST    := $(BINDIR)/$(SRC)

.PHONY: all install clean config

all: clean install

install: $(SRC)
	sudo install -d $(BINDIR)
	sudo install -m 0755 $(SRC) $(DEST)
	@echo "Installed $(SRC) -> $(DEST)"

clean:
	sudo rm -f $(DEST)
	@echo "Removed $(DEST)"

config:
	@if [ -z "$(TIMEOUT)" ]; then \
		read -p "Cache timeout in seconds (empty to skip cache): " TIMEOUT; \
	fi; \
	if [ -n "$$TIMEOUT" ]; then \
		git config --global credential.helper "cache --timeout $$TIMEOUT"; \
		echo "Added cache helper ($$TIMEOUT s)"; \
	else \
		echo "Skipping cache helper"; \
	fi
	git config --global credential.helper $(DEST)
	@echo "Configured git credential helper: $(SRC)"
