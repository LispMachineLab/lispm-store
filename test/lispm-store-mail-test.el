;;; lispm-store-mail-test.el --- Offline mail regressions -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ryan.K
;; SPDX-License-Identifier: AGPL-3.0-or-later

;;; Commentary:

;; Offline regressions for the Mail skill's timeout and approval-cache rules.

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'seq)
(require 'subr-x)

(declare-function lispm-use-mail--known nil (account mailbox uid))

(defconst lispm-store-mail-test--root
  (file-name-directory
   (directory-file-name
    (file-name-directory
     (or load-file-name (bound-and-true-p byte-compile-current-file) buffer-file-name)))))

(defun lispm-store-mail-test--forms ()
  "Read the Mail skill's actual load block without loading Mail."
  (with-temp-buffer
    (insert-file-contents (expand-file-name "skills/use-mail.org" lispm-store-mail-test--root))
    (goto-char (point-min))
    (search-forward "#+begin_src emacs-lisp :lispm load")
    (forward-line)
    (let ((end (save-excursion (search-forward "#+end_src") (line-beginning-position))) forms)
      (while (< (point) end)
        (skip-chars-forward " \t\n")
        (when (< (point) end) (push (read (current-buffer)) forms)))
      (nreverse forms))))

(dolist (form (lispm-store-mail-test--forms))
  (when (memq (car-safe form) '(defun defvar defconst))
    (eval form t)))

(defun lispm-store-mail-test--draft ()
  "Return the actual mail_draft body as a callable function."
  (let* ((form (seq-find (lambda (f) (and (eq (car-safe f) 'lispm-deftool)
                                         (eq (cadr f) 'mail_draft)))
                         (lispm-store-mail-test--forms)))
         (args (mapcar #'car (nth 2 form)))
         (body (nthcdr 3 form)))
    (when (stringp (car body)) (setq body (cdr body)))
    (while (keywordp (car body)) (setq body (cddr body)))
    (eval `(lambda (,@args done) ,@body) t)))

(ert-deftest lispm-store-mail-late-read-does-not-save ()
  (let (timeout read-callback saved result)
    (cl-letf (((symbol-function 'run-at-time)
               (lambda (_seconds _repeat fn &rest args)
                 (setq timeout (lambda () (apply fn args))) 'timer))
              ((symbol-function 'cancel-timer) #'ignore)
              ((symbol-function 'lispm-use-mail--account) (lambda (_) '(:address "a@example.org")))
              ((symbol-function 'lispm-use-mail--mailbox) (lambda (_ name) name))
              ((symbol-function 'lispm-mail-account-id) (lambda (_) "account"))
              ((symbol-function 'lispm-mail-read-message)
               (lambda (_id _box _uid cb) (setq read-callback cb)))
              ((symbol-function 'lispm-mail-reply-fields) (lambda (&rest _) '(:to "b@example.org")))
              ((symbol-function 'lispm-mail-save-draft) (lambda (&rest _) (setq saved t))))
      (funcall (lispm-store-mail-test--draft) "Reply" nil nil nil nil 1 "INBOX" nil
               (lambda (&rest args) (setq result args)))
      (funcall timeout)
      (should (equal result '("The mail server did not answer in time." t)))
      (funcall read-callback '(:text "original") nil)
      (should-not saved))))

(ert-deftest lispm-store-mail-reply-before-timeout-saves-once ()
  (let (timeout saved result)
    (cl-letf (((symbol-function 'run-at-time)
               (lambda (_seconds _repeat fn &rest args)
                 (setq timeout (lambda () (apply fn args))) 'timer))
              ((symbol-function 'cancel-timer) #'ignore)
              ((symbol-function 'lispm-use-mail--account) (lambda (_) '(:address "a@example.org")))
              ((symbol-function 'lispm-use-mail--mailbox) (lambda (_ name) name))
              ((symbol-function 'lispm-mail-account-id) (lambda (_) "account"))
              ((symbol-function 'lispm-mail-read-message)
               (lambda (_id _box _uid cb) (funcall cb '(:text "original") nil)))
              ((symbol-function 'lispm-mail-reply-fields)
               (lambda (&rest _) '(:to "b@example.org" :subject "Re: Hello")))
              ((symbol-function 'lispm-mail-save-draft)
               (lambda (fields cb) (push fields saved) (funcall cb "Drafts" nil))))
      (funcall (lispm-store-mail-test--draft) "Reply" nil nil nil nil 1 "INBOX" nil
               (lambda (&rest args) (push args result)))
      (should (= (length saved) 1))
      (should (equal (plist-get (car saved) :body) "Reply"))
      (should-not (cadar result))
      (funcall timeout)
      (should (= (length result) 1)))))

(ert-deftest lispm-store-mail-identity-follows-owner-cache ()
  (let ((current '(:uid 5 :subject "old")))
    (cl-letf (((symbol-function 'lispm-mail-account-id) (lambda (_) "account"))
              ((symbol-function 'lispm-mail-message) (lambda (&rest _) current)))
      (should (equal (plist-get (lispm-use-mail--known nil "INBOX" 5) :subject) "old"))
      (setq current nil)
      (should-not (lispm-use-mail--known nil "INBOX" 5))
      (setq current '(:uid 5 :subject "new"))
      (should (equal (plist-get (lispm-use-mail--known nil "INBOX" 5) :subject) "new")))))

(provide 'lispm-store-mail-test)
;;; lispm-store-mail-test.el ends here
