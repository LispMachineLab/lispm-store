;;; lispm-store-test-helpers.el --- Shared store test infrastructure  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ryan.K
;; SPDX-License-Identifier: AGPL-3.0-or-later

;;; Commentary:

;; Shared installation, child-Emacs, and skill-loading helpers for
;; LispM Store tests.  Contains no `ert-deftest' definitions, so offline
;; regression suites can load and exercise this harness without
;; registering network integration tests in global ERT state.

;;; Code:

(require 'cl-lib)
(require 'ert)
(require 'package)
(require 'package-vc)
(require 'seq)
(require 'subr-x)
(require 'lispm-store-check
         (expand-file-name
          "lispm-store-check.el"
          (file-name-directory
           (or load-file-name (bound-and-true-p byte-compile-current-file) buffer-file-name))))

(declare-function lispm-get-tool "lispm" (name))
(declare-function lispm-tool-function "lispm" (tool))

(defvar lispm-store-test--work (make-temp-file "lispm-store-test" t)
  "A directory owned by this test run, never an installed checkout.")

(defun lispm-store-test--cleanup ()
  "Remove this run's scratch tree, unless explicitly kept for diagnosis.
Set LISPM_STORE_TEST_KEEP_WORK to a nonempty value to retain it.  Only
this run's owned temporary directory is removed, not installed artifacts
outside it.  This also runs when setup or a test fails."
  (if (not (string-empty-p (or (getenv "LISPM_STORE_TEST_KEEP_WORK") "")))
      (message "Store test work retained at %s" lispm-store-test--work)
    (when (file-directory-p lispm-store-test--work)
      (delete-directory lispm-store-test--work t))))

(add-hook 'kill-emacs-hook #'lispm-store-test--cleanup)

(defvar lispm-store-test--ready nil
  "Non-nil once package archives and LispM Agent dependencies are initialized.")

(defun lispm-store-test--setup ()
  "Initialize this run's package directory and Agent dependencies once.
Loading this helper library alone does not install packages or use the network."
  (unless lispm-store-test--ready
    (setq package-user-dir (expand-file-name "elpa" lispm-store-test--work)
          package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                             ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                             ("melpa" . "https://melpa.org/packages/")))
    (package-initialize)
    (package-refresh-contents)
    (with-temp-buffer
      (insert-file-contents (or (locate-library "lispm.el" t)
                                (error "lispm-agent's lisp/ is not on the load path")))
      (pcase-dolist (`(,name . ,_version) (package-desc-reqs (package-buffer-info)))
        (unless (or (eq name 'emacs) (package-installed-p name)
                    (locate-library (concat (symbol-name name) ".el") t))
          (package-install name))))
    (require 'lispm)
    (setq lispm-store-test--ready t)))

(defvar lispm-store-test--items nil
  "The catalog's items, an alist (ID . PROPERTIES), once read.")

(defun lispm-store-test--items ()
  "Return the catalog's items, signaling an error if `make check' fails."
  (or lispm-store-test--items
      (pcase-let ((`(,items . ,problems) (lispm-store-check-catalog)))
        (when problems
          (error "The catalog has problems; run make check:\n%s" (string-join problems "\n")))
        (setq lispm-store-test--items items))))

(defun lispm-store-test--of-kind (kind)
  "Return catalog items whose `:kind' is KIND."
  (seq-filter (lambda (item) (eq (plist-get (cdr item) :kind) kind)) (lispm-store-test--items)))

(defun lispm-store-test--emacs (form)
  "Evaluate FORM in a fresh Emacs that has this run's packages.
An error there signals an error here, including stdout and stderr."
  (let ((log (make-temp-file (expand-file-name "emacs-log-" lispm-store-test--work))))
    (unwind-protect
        (with-temp-buffer
          (let ((status (call-process
                         (expand-file-name invocation-name invocation-directory) nil (list t log) nil
                         "-Q" "--batch" "--eval"
                         (format "%S" `(progn (require 'package)
                                              (require 'package-vc)
                                              (setq package-user-dir ,package-user-dir
                                                    package-archives ',package-archives)
                                              (package-initialize)
                                              (princ (format "\nlispm-store-value: %S\n" ,form)))))))
            (goto-char (point-max))
            (unless (and (eq status 0) (re-search-backward "^lispm-store-value: \\(.*\\)$" nil t))
              (error "A new Emacs failed (%s) evaluating %S:\nstdout:\n%s\nstderr:\n%s"
                     status form (buffer-string)
                     (with-temp-buffer (insert-file-contents log) (buffer-string))))
            (car (read-from-string (match-string 1)))))
      (delete-file log))))

(defvar lispm-store-test--installed nil
  "Non-nil once the apps' packages are installed.")

(defun lispm-store-test--in-install-order (items)
  "Return ITEMS, (ID . PROPERTIES) each, ordered after what they `:requires'."
  (let (order)
    (cl-labels ((visit (item)
                  (unless (memq item order)
                    (dolist (required (plist-get (cdr item) :requires))
                      (when-let* ((other (assq required items)))
                        (visit other)))
                    (push item order))))
      (mapc #'visit items))
    (nreverse order)))

(defun lispm-store-test--install ()
  "Install every app's and extension's package as LispM Desktop does, once."
  (lispm-store-test--setup)
  (unless lispm-store-test--installed
    (pcase-dolist (`(,_id . ,item) (lispm-store-test--in-install-order
                                    (append (lispm-store-test--of-kind 'app)
                                            (lispm-store-test--of-kind 'extension))))
      (pcase (plist-get item :package)
        ('nil)
        ((and (pred symbolp) name)
         (lispm-store-test--emacs `(progn (package-install ',name) t)))
        (`(,name . ,_spec)
         (when (lispm-store-test--emacs
                `(progn
                   (load ,(locate-library "lispm-desktop-store-installer") nil t)
                   (advice-add 'package-vc-install-dependencies :around
                               #'lispm-desktop-store-installer--libraries)
                   ;; Reuse the install primitive so :assets are excluded
                   ;; from package-vc's spec and fetched with pinned hashes.
                   (lispm-desktop-store--install-package ',(plist-get item :package))
                   (let ((unmet (seq-remove (lambda (requirement)
                                              (package-installed-p (car requirement) (cadr requirement)))
                                            (package-desc-reqs (cadr (assq ',name package-alist))))))
                     (dolist (requirement unmet)
                       (package-install (cadr (assq (car requirement) package-archive-contents))))
                     (and unmet t))))
           (lispm-store-test--emacs `(progn (package-vc-rebuild (cadr (assq ',name package-alist))) t))))))
    ;; Activate here what was installed there.
    (package-initialize)
    (setq lispm-store-test--installed t)))

(defun lispm-store-test--load-skill (file)
  "Evaluate the code of the skill in FILE, as LispM does when an agent loads it."
  (dolist (block (lispm-store-check--blocks (lispm-store-check--text file)))
    (with-temp-buffer
      (insert (nth 1 block))
      (goto-char (point-min))
      (while (progn (forward-comment (buffer-size)) (not (eobp)))
        (eval (read (current-buffer)) t)))))

(defun lispm-store-test--load-skills ()
  "Install what the skills require and load them all, LispM's web skill too."
  (lispm-store-test--install)
  (lispm-store-test--load-skill (expand-file-name "../skills/web.org"
                                                  (file-name-directory (locate-library "lispm"))))
  (pcase-dolist (`(,_id . ,item) (lispm-store-test--of-kind 'skill))
    (let ((file (plist-get item :file)))
      (lispm-store-test--load-skill (if (string-suffix-p "/" file) (concat file "SKILL.org") file)))))

(defun lispm-store-test--call (tool &rest args)
  "Call the tool TOOL with ARGS and return its result."
  (apply (lispm-tool-function (lispm-get-tool tool)) args))

(defun lispm-store-test--call-async (tool &rest args)
  "Call the asynchronous tool TOOL with ARGS and return its settled result."
  (let (result (deadline (+ (float-time) 60)))
    (apply (lispm-tool-function (lispm-get-tool tool))
           (lambda (value &optional failed) (setq result (list value failed)))
           args)
    (while (and (not result) (< (float-time) deadline))
      (accept-process-output nil 0.2))
    (should result)
    (should-not (nth 1 result))
    (car result)))

(defun lispm-store-test--desktop ()
  "Return the directories LispM Desktop loads from on `load-path'."
  (list (file-name-directory (or (locate-library "lispm-desktop-ai")
                                 (error "LispM Desktop's lisp/ is not on the load path")))
        (file-name-directory (or (locate-library "lispm-agents")
                                 (error "lispm-agent's lisp/ is not on the load path")))
        (file-name-directory (or (locate-library "lispm-ui")
                                 (error "LispM UI is not on the load path")))))

(provide 'lispm-store-test-helpers)
;;; lispm-store-test-helpers.el ends here
