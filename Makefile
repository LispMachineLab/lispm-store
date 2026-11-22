EMACS ?= emacs
# lisp/ of lispm-agent, whose skills these are: a checkout beside this one
# by default, as LispM Desktop looks for it.
LISPM_AGENT ?= ../lispm-agent/lisp
# lisp/ of LispM Desktop, whose editor the extensions extend: a checkout
# beside this one by default.
LISPM_DESKTOP ?= ../lispm-desktop/lisp
# LispM UI, the library LispM's agents and applications are drawn with: a
# checkout beside this one by default.
LISPM_UI ?= ../lispm-ui
LISPM_AUTH ?= ../lispm-auth
LISPM_KERNEL ?= ../lispm-kernel/lisp
AGENT_DEPS = $(foreach dir,$(wildcard $(LISPM_AUTH) $(LISPM_KERNEL)),-L $(dir))

.PHONY: check test test-offline

# The catalog and the files it names, read as LispM Desktop reads them,
# its applications and extensions by LispM Desktop's own rules
# (lispm-desktop-catalog.el).  Offline.
check:
	$(EMACS) -Q --batch -L $(LISPM_UI) -L $(LISPM_DESKTOP) -l test/lispm-store-check.el -f lispm-store-check

# Focused regressions use actual skill bodies with offline dependency stubs.
# No packages are installed and no messages are sent.
test-offline:
	$(EMACS) -Q --batch -L $(LISPM_UI) -L $(LISPM_DESKTOP) $(foreach file,$(filter-out test/lispm-store-test.el,$(wildcard test/*-test.el)),-l $(file)) -f ert-run-tests-batch-and-exit

# What check cannot see without installing: the apps' and extensions'
# packages, installed as LispM Desktop installs them, the extensions loaded
# beside it, the roles' tools and the skills at work.  Needs the network
# and git.
test:
	$(EMACS) -Q --batch -L $(LISPM_UI) $(AGENT_DEPS) -L $(LISPM_AGENT) -L $(LISPM_DESKTOP) -l test/lispm-store-test.el \
	  -f ert-run-tests-batch-and-exit
