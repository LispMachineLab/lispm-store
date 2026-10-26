The native code LispM's packages run, downloaded and checked.  You need not install it
yourself: the App Store installs it before LispM Remote, which uses it, and it works in any Emacs
30.1 or later.

## What it does

Some packages run native code: LispM Remote's Rings node is a module Emacs loads.  Nobody has to
build it or say where it is.  LispM Prebuilt downloads the one built for this computer, in the
background, so that Emacs does not wait, and keeps it only when its SHA-256 is the one pinned
beside the package's Lisp.  Those checksums come with the package's signed history, not with the
download, so a file changed after it was pinned is refused.  When LispM Kernel runs, the kernel
does the downloading.  Building from the sources is there for those who ask for it, never done
because a compiler happens to be around.

## For those writing a package

`lispm-prebuilt-define` says what a package ships, once:

```
(lispm-prebuilt-define 'lispm-gl-module
  :title "lispm-gl's module"
  :root (expand-file-name "native" directory)
  :sources '("Cargo.toml" "Cargo.lock" ("src" "\\.rs\\'"))
  :targets '("aarch64-apple-darwin" "x86_64-apple-darwin")
  :release "gl-module-%v" :asset "lispm-gl-module-%t%e.gz"
  :file "lispm-gl-module-%t%e"
  :url 'lispm-gl-module-prebuilt-url :source 'lispm-gl-module-source
  :sums (expand-file-name "lispm-gl-module-sums.eld" directory))
```

Then `lispm-prebuilt-get` has the file downloaded and checked in the background,
`lispm-prebuilt-load` loads a module, and `lispm-prebuilt-batch-pin` writes a release's pins.
Its [README](https://github.com/LispMachineLab/lispm-prebuilt) says the rest.  LispM Prebuilt is
free software, under the GNU Affero General Public License, version 3 or later.
