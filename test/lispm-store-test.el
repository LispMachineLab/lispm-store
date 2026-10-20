;;; lispm-store-test.el --- Install the store's items and try them  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ryan.K

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; `make test': what `make check' cannot see without installing.  Each
;; app's package is installed as LispM Desktop installs it, into a
;; package directory of this run's own: from the archives, or with
;; package-vc at the pinned commit.  Then its command must be there,
;; every tool a role names must be a tool once the skills are loaded,
;; and each skill's tools are called against the package it requires.
;;
;; It needs the network, git, and lispm-agent's lisp/ on the load path:
;;
;;   emacs -Q --batch -L ../lispm-agent/lisp -l test/lispm-store-test.el \
;;     -f ert-run-tests-batch-and-exit

;;; Code:

(require 'ert)
(require 'package)
(require 'package-vc)
(require 'lispm-store-check (expand-file-name "lispm-store-check.el"
                                              (file-name-directory (or load-file-name buffer-file-name))))

(defvar lispm-store-test--work (make-temp-file "lispm-store-test" t)
  "A directory of this run's own.")

;; Packages go to a directory of this run's, LispM's own dependencies
;; (its Package-Requires) first.
(setq package-user-dir (expand-file-name "elpa" lispm-store-test--work)
      package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(package-refresh-contents)
(with-temp-buffer
  (insert-file-contents (or (locate-library "lispm.el" t) (error "lispm-agent's lisp/ is not on the load path")))
  (pcase-dolist (`(,name . ,_version) (package-desc-reqs (package-buffer-info)))
    (unless (or (eq name 'emacs) (package-installed-p name))
      (package-install name))))
(require 'lispm)

(defvar lispm-store-test--items nil
  "The catalog's items, an alist (ID . PROPERTIES), once read.")

(defun lispm-store-test--items ()
  "The catalog's items; an error if `make check' would find problems."
  (or lispm-store-test--items
      (pcase-let ((`(,items . ,problems) (lispm-store-check-catalog)))
        (when problems
          (error "The catalog has problems; run make check:\n%s" (string-join problems "\n")))
        (setq lispm-store-test--items items))))

(defun lispm-store-test--of-kind (kind)
  "The items of KIND."
  (seq-filter (lambda (item) (eq (plist-get (cdr item) :kind) kind)) (lispm-store-test--items)))

(defun lispm-store-test--emacs (form)
  "What FORM evaluates to in a new Emacs that has this run's packages.
An error there is one here, with what that Emacs said."
  (let ((log (make-temp-file "lispm-store-emacs")))
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
        (unless (and (eq status 0) (re-search-backward "^lispm-store-value: \\(.*\\)$" nil t))
          (error "A new Emacs failed (%s) evaluating %S:\n%s" status form
                 (with-temp-buffer (insert-file-contents log) (buffer-string))))
        (car (read-from-string (match-string 1)))))))

(defvar lispm-store-test--installed nil
  "Non-nil once the apps' packages are installed.")

(defun lispm-store-test--install ()
  "Install every app's package as LispM Desktop does, once.
Each in an Emacs of its own, as installing loads what it compiles.
A package from git may require a newer version of a package Emacs
has built in, such as Compat: Emacs 30.1's package-vc leaves that
unmet, as it compares no versions (fixed in 30.2).  Then the newer
one is installed from the archives, and the package compiled again
in a new Emacs, which loads it rather than the built-in one."
  (unless lispm-store-test--installed
    (pcase-dolist (`(,_id . ,item) (lispm-store-test--of-kind 'app))
      (pcase (plist-get item :package)
        ('nil)
        ((and (pred symbolp) name)
         (lispm-store-test--emacs `(progn (package-install ',name) t)))
        (`(,name . ,spec)
         (when (lispm-store-test--emacs
                `(progn
                   (package-vc-install ',(cons name (cl-loop for (key value) on spec by #'cddr
                                                             unless (eq key :rev) append (list key value)))
                                       ,(plist-get spec :rev))
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
  "Call the tool TOOL with ARGS; its result."
  (apply (lispm-tool-function (lispm-get-tool tool)) args))

(defun lispm-store-test--call-async (tool &rest args)
  "Call the asynchronous tool TOOL with ARGS; its result, once it has one."
  (let (result (deadline (+ (float-time) 60)))
    (apply (lispm-tool-function (lispm-get-tool tool))
           (lambda (value &optional failed) (setq result (list value failed)))
           args)
    (while (and (not result) (< (float-time) deadline))
      (accept-process-output nil 0.2))
    (should result)
    (should-not (nth 1 result))
    (car result)))

;;;; Apps and roles

(ert-deftest lispm-store-test-apps-open ()
  "Each app's command is a command once its package is installed.
In a new Emacs, as after a restart: installing compiles a package,
which loads more of it than its autoloads."
  (lispm-store-test--install)
  (pcase-dolist (`(,id . ,item) (lispm-store-test--of-kind 'app))
    (let ((command (plist-get item :command))
          (feature (plist-get item :feature)))
      (should (equal (list id (lispm-store-test--emacs
                               (if command
                                   `(commandp ',command)
                                 `(featurep (require ',feature nil t)))))
                     (list id t))))))

(ert-deftest lispm-store-test-role-tools ()
  "Every tool a role names is a tool of LispM or of a skill."
  (lispm-store-test--load-skills)
  (pcase-dolist (`(,_id . ,item) (lispm-store-test--of-kind 'role))
    (let* ((file (plist-get item :file))
           (tools (cdr (assoc "tools" (car (lispm-store-check--keywords (lispm-store-check--text file)))))))
      (when tools
        (let ((tools (car (read-from-string tools))))
          (unless (eq tools t)
            (dolist (tool tools)
              (let ((name (symbol-name tool)))
                (should (equal (list file name
                                     (if (string-suffix-p "*" name)
                                         (seq-some (lambda (known) (string-prefix-p (substring name 0 -1) known))
                                                   (hash-table-keys lispm-tools--registry))
                                       (and (lispm-get-tool name) t)))
                               (list file name t)))))))))))

;;;; Skills

(defconst lispm-store-test--feed
  "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<feed xmlns=\"http://www.w3.org/2005/Atom\">
  <title>Test Planet</title>
  <link href=\"https://example.org/\"/>
  <id>urn:test:planet</id>
  <updated>2026-10-19T10:00:00Z</updated>
  <entry>
    <title>Lambda the ultimate</title>
    <link href=\"https://example.org/lambda\"/>
    <id>urn:test:1</id>
    <updated>2026-10-19T10:00:00Z</updated>
    <content type=\"html\">&lt;p&gt;First &lt;b&gt;paragraph&lt;/b&gt;.&lt;/p&gt;&lt;p&gt;Second.&lt;/p&gt;</content>
  </entry>
  <entry>
    <title>An episode</title>
    <link href=\"https://example.org/episode\"/>
    <link rel=\"enclosure\" type=\"audio/mpeg\" length=\"1000\" href=\"https://example.org/episode.mp3\"/>
    <id>urn:test:2</id>
    <updated>2026-10-18T10:00:00Z</updated>
    <summary>Plain text summary.</summary>
  </entry>
</feed>
"
  "A feed of two entries, one of them a podcast's.")

(ert-deftest lispm-store-test-feeds ()
  "The feeds skill fetches, finds, reads and tags Elfeed's entries."
  (lispm-store-test--load-skills)
  (let* ((feed (expand-file-name "feed.xml" lispm-store-test--work))
         (elfeed-db-directory (expand-file-name "elfeed" lispm-store-test--work))
         (elfeed-feeds (list (concat "file://" feed))))
    (with-temp-file feed (insert lispm-store-test--feed))
    (should (string-match-p "Fetched 1 feeds: 2 new entries" (lispm-store-test--call-async "feeds_update")))
    (should (string-match-p "Test Planet\n.*(2 unread)" (lispm-store-test--call "feeds_list")))
    (let* ((found (lispm-store-test--call "feeds_search" "+unread" nil))
           (keys (let (keys (start 0))
                   (while (string-match "^\\([0-9a-f]\\{10\\}\\)  " found start)
                     (push (match-string 1 found) keys)
                     (setq start (match-end 0)))
                   (nreverse keys))))
      (should (= (length keys) 2))
      (should (string-match-p "Lambda the ultimate" found))
      (let ((text (lispm-store-test--call "feeds_read" (car keys) nil)))
        (should (string-match-p "^Title: Lambda the ultimate$" text))
        ;; Elfeed renders HTML with libxml2, which some Emacs builds lack.
        (when (libxml-available-p)
          (should (string-match-p "First paragraph\\.\n+Second\\." text))))
      (should (string-match-p "^Enclosure: https://example.org/episode.mp3 (audio/mpeg)$"
                              (lispm-store-test--call "feeds_read" (cadr keys) nil)))
      (should (string-match-p "1 of 1 entries changed"
                              (lispm-store-test--call "feeds_tag" (vector (car keys)) ["starred"] ["unread"])))
      (should (string-match-p "Lambda the ultimate  (starred)"
                              (lispm-store-test--call "feeds_search" "-unread" nil)))
      (should (string-match-p "\\`No entries match"
                              (lispm-store-test--call "feeds_search" "+unread lambda" nil)))
      ;; Saved, and found again by a key no tool gave in this Emacs.
      (should (file-exists-p (expand-file-name "index" elfeed-db-directory)))
      (clrhash lispm-feeds--keys)
      (should (equal (elfeed-entry-title (lispm-feeds-entry (car keys))) "Lambda the ultimate"))
      (should-error (lispm-feeds-entry "0000000000")))))

(ert-deftest lispm-store-test-music ()
  "The music skill finds, plays, skips and pauses tracks with EMMS."
  (lispm-store-test--load-skills)
  (require 'emms-player-simple)
  ;; A player that plays nothing until it is stopped.
  (define-emms-simple-player lispm-store-test '(file) (regexp-opt '(".mp3" ".ogg")) "tail" "-f")
  (let* ((music (file-name-as-directory (expand-file-name "Music" lispm-store-test--work)))
         (emms-player-list '(emms-player-lispm-store-test))
         (emms-source-file-default-directory music))
    (dolist (file '("Coltrane/Blue Train/01 Blue Train.mp3" "Coltrane/Blue Train/02 Moment's Notice.mp3"
                    "Monk/Round Midnight.ogg" "Monk/notes.txt" ".hidden/secret.mp3"))
      (make-directory (file-name-directory (expand-file-name file music)) t)
      (with-temp-file (expand-file-name file music) (insert "x\n")))
    (unwind-protect
        (progn
          (should (equal (lispm-store-test--call "music_status") "Stopped; the playlist is empty."))
          (let ((found (lispm-store-test--call "music_find" "coltrane" nil nil)))
            (should (string-match-p "01 Blue Train.mp3\n.*02 Moment's Notice.mp3\\'" found)))
          (should (string-match-p "\\`None of the 3 music files"
                                  (lispm-store-test--call "music_find" "notes\\|secret" nil nil)))
          (should (string-match-p "\\`Playing: .*01 Blue Train.mp3, track 1 of 2\\.\\'"
                                  (lispm-store-test--call "music_play" (concat music "Coltrane") nil nil)))
          (should (string-match-p "track 2 of 2" (lispm-store-test--call "music_control" "next" nil)))
          (should-error (lispm-store-test--call "music_control" "next" nil))
          (should (string-match-p "\\`Playing: .*track 2 of 2" (lispm-store-test--call "music_status")))
          (should (string-match-p "\\`Paused: " (lispm-store-test--call "music_control" "pause" nil)))
          (should (string-match-p "\\`Playing: " (lispm-store-test--call "music_control" "resume" nil)))
          (should (string-match-p "track 2 of 3"
                                  (lispm-store-test--call "music_play" (concat music "Monk/Round Midnight.ogg")
                                                          t nil)))
          (should (string-match-p "Round Midnight.ogg, track 3 of 3"
                                  (lispm-store-test--call "music_play" nil nil 3)))
          (should (string-match-p "\n>   3\\. .*Round Midnight.ogg\\'" (lispm-store-test--call "music_playlist")))
          (should-error (lispm-store-test--call "music_play" nil nil 9))
          (should (string-match-p "\\`Stopped: " (lispm-store-test--call "music_control" "stop" nil))))
      (emms-stop))))

(provide 'lispm-store-test)
;;; lispm-store-test.el ends here
