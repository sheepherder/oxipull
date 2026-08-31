# SPDX-License-Identifier: GPL-3.0-or-later

PREFIX   ?= /usr/local
BINDIR   ?= $(PREFIX)/bin
RULESDIR ?= /etc/udev/rules.d
SHAREDIR ?= $(PREFIX)/share
UDEVADM  ?= udevadm

.PHONY: check install uninstall

check:
	@command -v python3 >/dev/null || { echo "Fehlt: python3" >&2; exit 1; }
	@python3 -c 'import sys; raise SystemExit(sys.version_info < (3, 10))' || { echo "Benötigt: Python 3.10 oder neuer" >&2; exit 1; }
	@MPLCONFIGDIR=/tmp/oxipull-matplotlib python3 -c 'import matplotlib; raise SystemExit(tuple(map(int, matplotlib.__version__.split(".")[:2])) < (3, 6))' 2>/dev/null || { echo "Benötigt: Python-Modul matplotlib 3.6 oder neuer" >&2; exit 1; }
	@command -v "$(UDEVADM)" >/dev/null || { echo "Fehlt: udevadm" >&2; exit 1; }
	@echo "Alle Abhängigkeiten sind vorhanden."

install: check
	install -d "$(BINDIR)" "$(RULESDIR)" \
		"$(SHAREDIR)/bash-completion/completions" \
		"$(SHAREDIR)/zsh/site-functions" \
		"$(SHAREDIR)/fish/vendor_completions.d" \
		"$(SHAREDIR)/licenses/oxipull"
	install -m 0755 oxipull "$(BINDIR)/oxipull"
	install -m 0644 60-checkme-o2.rules "$(RULESDIR)/60-checkme-o2.rules"
	install -m 0644 LICENSE "$(SHAREDIR)/licenses/oxipull/LICENSE"
	./oxipull completion bash > "$(SHAREDIR)/bash-completion/completions/oxipull"
	./oxipull completion zsh > "$(SHAREDIR)/zsh/site-functions/_oxipull"
	./oxipull completion fish > "$(SHAREDIR)/fish/vendor_completions.d/oxipull.fish"
	$(UDEVADM) control --reload-rules
	@echo "Oxipull ist installiert. USB-Gerät neu verbinden."

uninstall:
	rm -f "$(BINDIR)/oxipull" "$(RULESDIR)/60-checkme-o2.rules" \
		"$(SHAREDIR)/bash-completion/completions/oxipull" \
		"$(SHAREDIR)/zsh/site-functions/_oxipull" \
		"$(SHAREDIR)/fish/vendor_completions.d/oxipull.fish" \
		"$(SHAREDIR)/licenses/oxipull/LICENSE"
	$(UDEVADM) control --reload-rules
	@echo "Oxipull wurde entfernt."
