EMACS ?= emacs
# lisp/ of lispm-agent, whose skills these are: a checkout beside this one
# by default, as LispM Desktop looks for it.
LISPM_AGENT ?= ../lispm-agent/lisp
# lisp/ of LispM Desktop, whose editor the extensions extend: a checkout
# beside this one by default.
LISPM_DESKTOP ?= ../lispm-desktop/lisp

.PHONY: check test

# The catalog and the files it names, read as LispM Desktop reads them.
# Offline, and nothing beyond Emacs.
check:
	$(EMACS) -Q --batch -l test/lispm-store-check.el -f lispm-store-check

# What check cannot see without installing: the apps' and extensions'
# packages, installed as LispM Desktop installs them, the extensions loaded
# beside it, the roles' tools and the skills at work.  Needs the network
# and git.
test:
	$(EMACS) -Q --batch -L $(LISPM_AGENT) -L $(LISPM_DESKTOP) -l test/lispm-store-test.el \
	  -f ert-run-tests-batch-and-exit
