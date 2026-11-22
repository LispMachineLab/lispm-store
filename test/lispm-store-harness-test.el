;;; lispm-store-harness-test.el --- Offline harness regressions -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ryan.K
;; SPDX-License-Identifier: AGPL-3.0-or-later

;;; Commentary:

;; Offline unit tests for the store test and check infrastructure.

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'lispm-store-test-helpers
         (expand-file-name
          "lispm-store-test-helpers.el"
          (file-name-directory
           (or load-file-name (bound-and-true-p byte-compile-current-file) buffer-file-name))))
(require 'lispm-desktop-store-installer)

(ert-deftest lispm-store-harness-load-is-offline ()
  "Loading the shared harness starts no network setup or network tests."
  (should-not lispm-store-test--ready)
  (should-not lispm-store-test--installed)
  (should-not (ert-select-tests "^lispm-store-test-" t)))

(ert-deftest lispm-store-harness-child-logs-cleaned ()
  (let ((package-user-dir (expand-file-name "unused-elpa" lispm-store-test--work)))
    (should (equal (lispm-store-test--emacs '(list 1 2)) '(1 2)))
    (should-error (lispm-store-test--emacs '(error "child failure")))
    (cl-letf (((symbol-function 'call-process)
               (lambda (&rest _) (error "could not start child"))))
      (should-error (lispm-store-test--emacs t)))
    (should-not (directory-files lispm-store-test--work nil "^emacs-log-"))))

(ert-deftest lispm-store-harness-malformed-requires ()
  (dolist (requires '(not-a-list (other . tail) nil))
    (let ((lispm-store-check--problems nil))
      (lispm-store-check--requires
       `((broken :kind role :requires ,requires) (other :kind role)))
      (should (seq-some (lambda (problem) (string-match-p "list of item IDs" problem))
                        lispm-store-check--problems))))
  (let ((lispm-store-check--problems nil))
    (lispm-store-check--requires '((a :kind role :requires (b)) (b :kind role :requires (a))))
    (should (seq-some (lambda (problem) (string-match-p "circle" problem))
                      lispm-store-check--problems))))

(ert-deftest lispm-store-harness-install-uses-production-assets ()
  "Evaluate the generated install job with local package and download stubs."
  (let* ((directory (make-temp-file (expand-file-name "asset-" lispm-store-test--work) t))
         (package-user-dir directory)
         (bytes "offline native fixture")
         (sha (secure-hash 'sha256 bytes))
         (spec `(fixture :url "https://example.invalid/fixture" :rev "pinned"
                         :assets (("fixture.so" :url "https://example.invalid/asset" :sha256 ,sha))))
         (item `(fixture :kind app :package ,spec))
         (lispm-store-test--installed nil)
         (package-alist nil)
         installed-spec installed-rev)
    (unwind-protect
        (cl-letf (((symbol-function 'lispm-store-test--setup) #'ignore)
                  ((symbol-function 'lispm-store-test--of-kind)
                   (lambda (kind) (and (eq kind 'app) (list item))))
                  ((symbol-function 'package-initialize) #'ignore)
                  ((symbol-function 'package-vc-install)
                   (lambda (package &optional rev &rest _)
                     (setq installed-spec package installed-rev rev
                           package-alist
                           (list (list 'fixture
                                       (package-desc-create :name 'fixture :version '(1)
                                                            :dir directory :reqs nil))))))
                  ((symbol-function 'lispm-desktop-store--download) (lambda (_) bytes))
                  ((symbol-function 'lispm-store-test--emacs)
                   (lambda (form)
                     ;; Installer is already loaded; reloading would replace
                     ;; our download stub.  Never perform network I/O here.
                     (unwind-protect
                         (cl-letf (((symbol-function 'load) #'ignore))
                           (eval form t))
                       (advice-remove 'package-vc-install-dependencies
                                      #'lispm-desktop-store-installer--libraries)))))
          (lispm-store-test--install)
          (should (equal installed-rev "pinned"))
          (should-not (plist-member (cdr installed-spec) :assets))
          (should-not (plist-member (cdr installed-spec) :rev))
          (should (equal (with-temp-buffer
                           (insert-file-contents-literally (expand-file-name "fixture.so" directory))
                           (buffer-string)) bytes))
          ;; The real installer also rejects incorrect pinned bytes.
          (cl-letf (((symbol-function 'lispm-desktop-store--download) (lambda (_) "corrupt")))
            (should-error (lispm-desktop-store--install-package spec))))
      (delete-directory directory t))))

(ert-deftest lispm-store-harness-cleanup-owned-tree ()
  (let* ((lispm-store-test--work (make-temp-file "lispm-store-harness-owned-" t))
         (process-environment (cons "LISPM_STORE_TEST_KEEP_WORK=" process-environment)))
    (unwind-protect
        (progn
          (with-temp-file (expand-file-name "scratch" lispm-store-test--work) (insert "fixture"))
          (let ((process-environment (cons "LISPM_STORE_TEST_KEEP_WORK=1" process-environment)))
            (lispm-store-test--cleanup)
            (should (file-directory-p lispm-store-test--work)))
          (lispm-store-test--cleanup)
          (should-not (file-exists-p lispm-store-test--work)))
      (when (file-directory-p lispm-store-test--work)
        (delete-directory lispm-store-test--work t)))))

(provide 'lispm-store-harness-test)
;;; lispm-store-harness-test.el ends here
