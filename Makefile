PREFIX     ?= /usr/local
BINDIR     ?= $(PREFIX)/bin
DATADIR    ?= $(PREFIX)/share
MANDIR     ?= $(DATADIR)/man/man1
DOCDIR     ?= $(DATADIR)/doc/goto
BASHCOMPDIR ?= $(DATADIR)/bash-completion/completions
ZSHCOMPDIR  ?= $(DATADIR)/zsh/vendor-completions
FISHCOMPDIR ?= $(DATADIR)/fish/vendor_completions.d

.PHONY: all install uninstall lint test clean

all:
	@echo "goto is a shell script — nothing to build."
	@echo "Run 'make install' to install or 'make test' to run tests."

install:
	install -Dm755 goto                    $(DESTDIR)$(BINDIR)/goto
	install -Dm644 goto.sh                 $(DESTDIR)$(DATADIR)/goto/goto.sh
	install -Dm644 goto.1                  $(DESTDIR)$(MANDIR)/goto.1
	install -Dm644 completions/goto.bash   $(DESTDIR)$(BASHCOMPDIR)/goto
	install -Dm644 completions/_goto       $(DESTDIR)$(ZSHCOMPDIR)/_goto
	install -Dm644 completions/goto.fish   $(DESTDIR)$(FISHCOMPDIR)/goto.fish
	install -Dm644 LICENSE                 $(DESTDIR)$(DOCDIR)/LICENSE
	install -Dm644 README.md               $(DESTDIR)$(DOCDIR)/README.md
	@echo ""
	@echo "Installed goto to $(DESTDIR)$(BINDIR)/goto"
	@echo ""
	@echo "Add to your shell config:"
	@echo "  Bash/Zsh: source $(DATADIR)/goto/goto.sh"
	@echo "  Fish:     auto-loaded from $(FISHCOMPDIR)/goto.fish"

uninstall:
	rm -f  $(DESTDIR)$(BINDIR)/goto
	rm -f  $(DESTDIR)$(DATADIR)/goto/goto.sh
	rm -f  $(DESTDIR)$(MANDIR)/goto.1
	rm -f  $(DESTDIR)$(BASHCOMPDIR)/goto
	rm -f  $(DESTDIR)$(ZSHCOMPDIR)/_goto
	rm -f  $(DESTDIR)$(FISHCOMPDIR)/goto.fish
	rm -f  $(DESTDIR)$(DOCDIR)/LICENSE
	rm -f  $(DESTDIR)$(DOCDIR)/README.md
	rmdir  $(DESTDIR)$(DATADIR)/goto 2>/dev/null || true
	rmdir  $(DESTDIR)$(DOCDIR) 2>/dev/null || true

lint:
	shellcheck goto goto.sh install.sh verify.sh completions/goto.bash

test:
	@./verify.sh

clean:
	@echo "Nothing to clean."
