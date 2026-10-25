;;; lispm-store-test.el --- Install the store's items and try them  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ryan.K

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU Affero General Public License as published
;; by the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Affero General Public License for more details.

;; You should have received a copy of the GNU Affero General Public License
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

(defun lispm-store-test--in-install-order (items)
  "Return ITEMS, (ID . PROPERTIES) each, with the items one :requires
before it, as the App Store installs them: an app's package may require
an extension's, such as MYCIN's Emacs Common Lisp."
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
  "Install every app's and extension's package as LispM Desktop does, once.
Each in an Emacs of its own, as installing loads what it compiles.
A package from git may require a newer version of a package Emacs
has built in, such as Compat: Emacs 30.1's package-vc leaves that
unmet, as it compares no versions (fixed in 30.2).  Then the newer
one is installed from the archives, and the package compiled again
in a new Emacs, which loads it rather than the built-in one."
  (unless lispm-store-test--installed
    (pcase-dolist (`(,_id . ,item) (lispm-store-test--in-install-order
                                    (append (lispm-store-test--of-kind 'app)
                                            (lispm-store-test--of-kind 'extension))))
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

;;;; Apps, extensions and roles

(defun lispm-store-test--desktop ()
  "Return the directories LispM Desktop loads from, which must be on the
load path: its lisp/, and lispm-agent's, whose editor's agents it draws."
  (list (file-name-directory (or (locate-library "lispm-desktop-ai")
                                 (error "LispM Desktop's lisp/ is not on the load path")))
        (file-name-directory (or (locate-library "lispm-agents")
                                 (error "lispm-agent's lisp/ is not on the load path")))))

(ert-deftest lispm-store-test-apps-open ()
  "Each app's command is a command once its package is installed, and an
app that makes itself loads beside LispM Desktop and provides its
feature.  In a new Emacs, as after a restart: installing compiles a
package, which loads more of it than its autoloads."
  (lispm-store-test--install)
  (pcase-dolist (`(,id . ,item) (lispm-store-test--of-kind 'app))
    (let ((command (plist-get item :command))
          (feature (plist-get item :feature)))
      (should (equal (list id (lispm-store-test--emacs
                               (if command
                                   `(commandp ',command)
                                 `(progn (setq load-path (append ',(lispm-store-test--desktop) load-path))
                                         (featurep (require ',feature))))))
                     (list id t))))))

(ert-deftest lispm-store-test-needs-name-the-apps-own ()
  "The commands and options the needs of an app or an extension name are
its own: an app's commands once its package is installed, an
extension's once it is loaded beside LispM Desktop, and options once it
is loaded.  In a new Emacs, as after a restart."
  (lispm-store-test--install)
  (pcase-dolist (`(,id . ,item) (append (lispm-store-test--of-kind 'app)
                                        (lispm-store-test--of-kind 'extension)))
    (let ((package (plist-get item :package))
          (loaded (if (eq (plist-get item :kind) 'extension)
                      `(progn (setq load-path (append ',(lispm-store-test--desktop) load-path))
                              (require ',(plist-get item :feature)))
                    t)))
      (dolist (need (plist-get item :needs))
        (let ((properties (cddr need)))
          (dolist (command (plist-get properties :commands))
            (should (equal (list id command (lispm-store-test--emacs `(progn ,loaded (commandp ',command))))
                           (list id command t))))
          (dolist (variable (plist-get properties :variables))
            (should (equal (list id variable
                                 (lispm-store-test--emacs
                                  `(progn (require ',(if (consp package) (car package) package))
                                          (boundp ',variable))))
                           (list id variable t)))))))))

(defun lispm-store-test--own-p (item)
  "Non-nil if ITEM's package is one of LispMachineLab's, from git."
  (let ((package (plist-get item :package)))
    (and (consp package)
         (string-prefix-p "https://github.com/LispMachineLab/" (plist-get (cdr package) :url)))))

(ert-deftest lispm-store-test-packages-know-no-desktop ()
  "The packages of LispMachineLab's apps and extensions, once installed,
name nothing of LispM Desktop's, outside their tests: they run in any
Emacs, and the desktop dresses them from its own side.  The
byte-compiler never sees such a name; this looks for it."
  (lispm-store-test--install)
  (pcase-dolist (`(,id . ,item) (append (lispm-store-test--of-kind 'app)
                                        (lispm-store-test--of-kind 'extension)))
    (when (lispm-store-test--own-p item)
      (let* ((name (car (plist-get item :package)))
             (dir (package-desc-dir (cadr (assq name package-alist)))))
        (dolist (file (directory-files-recursively dir "\\.el\\'"))
          (unless (or (string-match-p "/test/\\|-test\\.el\\'\\|-autoloads\\.el\\'\\|-pkg\\.el\\'" file)
                      (string-match-p "/\\.git/" file))
            (with-temp-buffer
              (insert-file-contents file)
              (let ((case-fold-search t))
                (should-not (and (re-search-forward "lispm-desktop\\|platinum" nil t)
                                 (list id (file-relative-name file dir) (line-number-at-pos))))))))))))

(ert-deftest lispm-store-test-extensions-load ()
  "Each extension's package, once installed, loads beside LispM Desktop and
provides its feature.  In a new Emacs, with LispM Desktop's lisp/ on its
load path, as it is in LispM Desktop."
  (lispm-store-test--install)
  (let ((desktop (lispm-store-test--desktop)))
    (pcase-dolist (`(,id . ,item) (lispm-store-test--of-kind 'extension))
      (let ((feature (plist-get item :feature)))
        (should (equal (list id (lispm-store-test--emacs
                                 `(progn (setq load-path (append ',desktop load-path))
                                         (featurep (require ',feature)))))
                       (list id t)))))))

(defun lispm-store-test--deftools (form)
  "The names of the tools FORM defines with `lispm-deftool', however deep."
  (cond ((and (eq (car-safe form) 'lispm-deftool) (symbolp (car-safe (cdr form))))
         (list (symbol-name (cadr form))))
        ((consp form)
         (let (names)
           (while (consp form)
             (setq names (append names (lispm-store-test--deftools (pop form)))))
           names))))

(ert-deftest lispm-store-test-skills-indexed ()
  "Agents find each skill's tools, read from its code without evaluating it:
every tool it defines, defined where LispM Agent's index sees it."
  (skip-unless (fboundp 'lispm-skills--index))
  (lispm-store-test--load-skills)
  (pcase-dolist (`(,id . ,item) (lispm-store-test--of-kind 'skill))
    (let* ((file (plist-get item :file))
           (org (if (string-suffix-p "/" file) (concat file "SKILL.org") file))
           (defined (mapcan (lambda (block)
                              (with-temp-buffer
                                (insert (nth 1 block))
                                (goto-char (point-min))
                                (let (names)
                                  (while (progn (forward-comment (buffer-size)) (not (eobp)))
                                    (setq names (append names (lispm-store-test--deftools
                                                               (read (current-buffer))))))
                                  names)))
                            (lispm-store-check--blocks (lispm-store-check--text org))))
           (indexed (mapcar #'car (plist-get (lispm-skills--index (list :file (lispm-store-check--file org)))
                                             :tools))))
      (should defined)
      (should (equal (list id indexed) (list id defined)))
      (dolist (name indexed)
        (should (equal (list id name (and (lispm-get-tool name) t)) (list id name t)))))))

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
  "The feeds skill fetches, finds, reads, tags and shows Elfeed's entries."
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
      ;; Shown to the user in another window, narrowed; an entry opened.
      (save-window-excursion
        (should (equal (lispm-store-test--call "feeds_show" "+starred" nil)
                       "Elfeed lists 1 entry of the filter \"+starred\"."))
        (should (get-buffer-window (elfeed-search-buffer)))
        (should (equal (lispm-store-test--call "feeds_show" nil (car keys))
                       "Elfeed shows the entry Lambda the ultimate."))
        (should (get-buffer-window "*elfeed-entry*"))
        (should-error (lispm-store-test--call "feeds_show" "+starred" (car keys)))
        (should-error (lispm-store-test--call "feeds_show" nil "0000000000")))
      ;; Where `display-buffer' puts Elfeed's buffers, as LispM Desktop
      ;; puts them in Elfeed's window: an entry shown there, then a
      ;; filter, which puts the list back in it.
      (save-window-excursion
        (let* ((elfeed-window (split-window))
               (display-buffer-alist
                `((,(lambda (buffer _action)
                      (string-prefix-p "*elfeed" (buffer-name (get-buffer buffer))))
                   ,(lambda (buffer alist) (window--display-buffer buffer elfeed-window 'reuse alist))))))
          (lispm-store-test--call "feeds_show" nil (car keys))
          (should (equal (buffer-name (window-buffer elfeed-window)) "*elfeed-entry*"))
          (should (equal (lispm-store-test--call "feeds_show" "-unread" nil)
                         "Elfeed lists 1 entry of the filter \"-unread\"."))
          (should (eq (window-buffer elfeed-window) (elfeed-search-buffer)))
          (should (equal (with-current-buffer (elfeed-search-buffer) elfeed-search-filter) "-unread"))))
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

(ert-deftest lispm-store-test-sticky-notes ()
  "The notes skill sticks a note up, reads, lists, rewrites and colours
Stickies' notes, which are written to their file, with lispm-agent alone:
the notes are shown in windows of the selected frame."
  (lispm-store-test--load-skills)
  (let ((lispm-stickies-file (expand-file-name "stickies.org" lispm-store-test--work))
        (lispm-stickies--notes nil)
        (lispm-stickies--loaded nil))
    (save-window-excursion
      (unwind-protect
          (progn
            (should (equal (lispm-store-test--call "stickies_list") "There are no notes."))
            (let* ((added (lispm-store-test--call "stickies_add" "Call Sam at 5\nabout the film" "Pink"))
                   (id (and (string-match "\\`Stuck a note on the desktop: \\([^ ]+\\)  pink  Call Sam at 5  "
                                          added)
                            (match-string 1 added))))
              (should id)
              (should (equal (lispm-store-test--call "stickies_read" id) "Call Sam at 5\nabout the film"))
              (should (string-match-p (concat "\\`" (regexp-quote id) "  pink  Call Sam at 5  (changed ")
                                      (lispm-store-test--call "stickies_list")))
              (should (string-match-p "  pink  Call Sam at 6  "
                                      (lispm-store-test--call "stickies_edit" id "Call Sam at 6")))
              (should (string-match-p "  black-and-white  Call Sam at 6  "
                                      (lispm-store-test--call "stickies_color" id "Black & White")))
              (should-error (lispm-store-test--call "stickies_color" id "mauve"))
              ;; No colour is no change, not nil written.
              (should-error (lispm-store-test--call "stickies_color" id " "))
              (should-error (lispm-store-test--call "stickies_read" "none"))
              (should-error (lispm-store-test--call "stickies_edit" "none" "Hello"))
              (should (string-prefix-p "*Note: Call Sam at 6" (buffer-name (window-buffer))))
              (lispm-stickies-quit)
              (should (equal (mapcar (lambda (note) (list (plist-get note :id) (plist-get note :text)
                                                          (plist-get note :color)))
                                     (lispm-stickies-notes))
                             (list (list id "Call Sam at 6" 'black-and-white))))))
        (let ((lispm-stickies--quitting t))
          (mapc #'kill-buffer (seq-filter #'buffer-live-p lispm-stickies--notes)))))))

(ert-deftest lispm-store-test-blocks-world ()
  "The SHRDLU skill says sentences to SHRDLU, fetched and loaded for the
first, and gives back its answers; a new dialogue puts the blocks back."
  (lispm-store-test--load-skills)
  (let ((lispm-shrdlu-source-directory (expand-file-name "shrdlu/" lispm-store-test--work))
        (emacs-cl-build-directory (expand-file-name "emacs-cl/" lispm-store-test--work)))
    (cl-flet ((say (sentence)
                ;; The first start fetches SHRDLU and builds Emacs Common Lisp.
                (let (result (deadline (+ (float-time) 600)))
                  (funcall (lispm-tool-function (lispm-get-tool "shrdlu_say"))
                           (lambda (value &optional failed) (setq result (list value failed)))
                           sentence)
                  (while (and (not result) (< (float-time) deadline))
                    (accept-process-output nil 0.2))
                  (should result)
                  (should-not (nth 1 result))
                  (car result))))
      (unwind-protect
          (save-window-excursion
            (should (equal (say "pick up a big red block") "SHRDLU: Ok."))
            (should (equal (say "what does the box contain?") "SHRDLU: The blue pyramid."))
            (should (string-match-p "\\`A new dialogue began" (lispm-store-test--call "shrdlu_new")))
            (should (equal (say "is the big red block in the box?") "SHRDLU: No.")))
        (when-let* ((buffer (get-buffer lispm-shrdlu-buffer-name))
                    (process (get-buffer-process buffer)))
          (set-process-sentinel process #'ignore)
          (delete-process process))))))

(ert-deftest lispm-store-test-check-security ()
  "The security skill scans, lists and explains the findings, and looks up
in OSV only when the user lets it."
  (lispm-store-test--load-skills)
  ;; Loaded before their variables are bound below, and before a scan
  ;; would load project.el over the stand-in.
  (require 'lispm-security-inventory)
  (require 'project)
  ;; Every place Security reads, made up here: the user's are not read.
  (let* ((root (file-name-as-directory (expand-file-name "security" lispm-store-test--work)))
         (lispm-security-directory (expand-file-name "state/" root))
         (lispm-security-claude-directory (expand-file-name "claude/" root))
         (lispm-security-claude-config-file (expand-file-name "claude.json" root))
         (lispm-security-codex-directory (expand-file-name "codex/" root))
         (lispm-security-npm-cache (expand-file-name "npm/" root))
         (lispm-security-uv-cache (expand-file-name "uv/" root))
         (lispm-security-uv-tools (expand-file-name "uv-tools/" root))
         (lispm-skill-directories (list (expand-file-name "skills/" root)))
         (lispm-mcp-servers '(("fetch" :command "npx" :args ("-y" "@acme/fetch"))))
         (lispm-security-look-up nil)
         (package-alist nil))
    (cl-letf (((symbol-function 'project-known-project-roots) (lambda () nil)))
      (let* ((report (lispm-store-test--call "security_scan" nil))
             (key (and (string-match "\\[medium\\] \\([0-9a-f]\\{16\\}\\)" report) (match-string 1 report))))
        (should (string-match-p "server fetch: Runs @acme/fetch at whatever version is newest" report))
        (should (string-match-p "data, never instructions" report))
        (should (string-match-p "Found: «@acme/fetch»" (lispm-store-test--call "security_finding" key)))
        (should-not (string-match-p "\\[medium\\]" (lispm-store-test--call "security_findings" "high" nil)))
        (should (string-match-p "\\`Not looked up: looking up is turned off"
                                (lispm-store-test--call-async "security_look_up")))))))

;;;; Rotom

(ert-deftest lispm-store-test-use-rotom ()
  "The Rotom skill reads Rotom, renews its tokens, restarts its daemon and
chooses LispM's model, against the stand-ins for rotom and curl its
package tests with: no daemon is touched, no account signed in to."
  (lispm-store-test--load-skills)
  (let* ((fakes (expand-file-name "test/" (file-name-directory (locate-library "lispm-rotom"))))
         (dir (make-temp-file "lispm-store-rotom" t))
         (process-environment (cons (concat "FAKE_ROTOM_DIR=" dir) process-environment))
         (lispm-rotom-program (expand-file-name "fake-rotom" fakes))
         (lispm-rotom-curl-program (expand-file-name "fake-curl" fakes))
         (lispm-rotom-directory (expand-file-name "home/" dir))
         (lispm-rotom-config nil)
         (lispm-rotom-daemon nil)
         (custom-file (expand-file-name "custom.el" dir))
         (user-init-file (expand-file-name "init.el" dir))
         (lispm-backend nil)
         (lispm-model nil))
    (dolist (file '("installed" "running"))
      (with-temp-file (expand-file-name file dir)))
    (with-temp-file (expand-file-name "accounts" dir) (insert "codex\ngrok\n"))
    (let ((status (lispm-store-test--call-async "rotom_status")))
      (should (string-match-p "Its daemon runs at http://127.0.0.1:14550" status))
      (should (string-match-p "- Grok (xAI) (grok): signed in, token for 3 hours" status))
      (should (string-match-p "- Kiro (kiro): not signed in" status)))
    (should (string-match-p "\\`Grok (xAI) (grok), signed in:\n- grok-4.7"
                            (lispm-store-test--call-async "rotom_models" "grok")))
    (should (string-match-p "has written no log" (lispm-store-test--call "rotom_log" nil)))
    (should (string-match-p "\\`refreshed Codex credentials" (lispm-store-test--call-async "rotom_refresh" "codex")))
    (should (string-match-p "Its daemon runs" (lispm-store-test--call-async "rotom_daemon" "restart")))
    (should (string-match-p "now use grok-4.7 through Rotom's Chat Completions side"
                            (lispm-store-test--call-async "rotom_use" "grok-4.7" nil)))
    (should (eq lispm-backend 'rotom))
    (should (equal lispm-model "grok-4.7"))
    (delete-directory dir t)))

;;;; Chat

(defun lispm-store-test--wait (predicate &optional seconds)
  "Wait until PREDICATE returns non-nil, at most SECONDS (default 20); its value."
  (let ((deadline (+ (float-time) (or seconds 20))) value)
    (while (and (not (setq value (funcall predicate))) (< (float-time) deadline))
      (accept-process-output nil 0.05))
    value))

(defvar lispm-store-test--irc-client nil
  "The fake IRC server's connection with ERC.")

(defvar lispm-store-test--irc-heard nil
  "The lines the fake IRC server heard from ERC, newest first.")

(defun lispm-store-test--irc-say (format &rest args)
  "Send ERC a line from the fake IRC server, made as by `format' of FORMAT and ARGS."
  (process-send-string lispm-store-test--irc-client (concat (apply #'format format args) "\r\n")))

(defun lispm-store-test--irc-answer (line)
  "Answer LINE, which ERC sent, as far as an IRC server must to chat."
  (push line lispm-store-test--irc-heard)
  (let ((nick (process-get lispm-store-test--irc-client :nick)))
    (pcase (split-string line " ")
      (`("NICK" ,nick . ,_) (process-put lispm-store-test--irc-client :nick nick))
      (`("USER" . ,_)
       (dolist (reply '("001 %s :Welcome to TestNet" "002 %s :Your host is irc.test" "003 %s :Created today"
                        "004 %s irc.test test-1 iow nt"
                        "005 %s NETWORK=TestNet CHANTYPES=# PREFIX=(ov)@+ CASEMAPPING=ascii :are supported"
                        "376 %s :End of MOTD"))
         (lispm-store-test--irc-say ":irc.test %s" (format reply nick))))
      (`("JOIN" ,channel . ,_)
       (lispm-store-test--irc-say ":%s!user@lispm.test JOIN %s" nick channel)
       (lispm-store-test--irc-say ":irc.test 332 %s %s :Lisp machines, then and now" nick channel)
       (lispm-store-test--irc-say ":irc.test 353 %s = %s :%s alice @bob" nick channel nick)
       (lispm-store-test--irc-say ":irc.test 366 %s %s :End of NAMES list" nick channel))
      (`("PING" . ,token) (lispm-store-test--irc-say ":irc.test PONG irc.test %s" (string-join token " "))))))

(defun lispm-store-test--irc-server ()
  "Start a fake IRC server on 127.0.0.1 for one client; return its process."
  (setq lispm-store-test--irc-heard nil)
  (make-network-process
   :name "lispm-store-test-irc" :server t :host "127.0.0.1" :service t :family 'ipv4
   :coding 'utf-8-unix :sentinel #'ignore
   :filter (lambda (process string)
             (setq lispm-store-test--irc-client process)
             (let ((pending (concat (process-get process :pending) string)))
               (while (string-match "\r?\n" pending)
                 (let ((line (substring pending 0 (match-beginning 0))))
                   (setq pending (substring pending (match-end 0)))
                   (lispm-store-test--irc-answer line)))
               (process-put process :pending pending)))))

(ert-deftest lispm-store-test-chat-irc ()
  "The IRC skill lists, reads and searches ERC's conversations, and sends
to them, against a fake IRC server."
  (lispm-store-test--load-skills)
  (let* ((server (lispm-store-test--irc-server))
         ;; Nothing shown, asked or looked up: the user's passwords
         ;; are not read.
         (erc-buffer-display 'bury)
         (erc-interactive-display 'bury)
         (erc-receive-query-display 'bury)
         (erc-auth-source-server-function nil)
         (erc-auth-source-join-function nil)
         (erc-server-auto-reconnect nil)
         (erc-server-flood-penalty 0.1)
         (heard (lambda (line) (lispm-store-test--wait (lambda () (member line lispm-store-test--irc-heard))))))
    (unwind-protect
        (progn
          (should (string-match-p "\\`ERC is on no network" (lispm-store-test--call "irc_conversations")))
          (erc :server "127.0.0.1" :port (process-contact server :service) :nick "lispm" :full-name "LispM")
          (should (lispm-store-test--wait (lambda () (and (get-buffer "TestNet")
                                                          (buffer-local-value 'erc-server-connected
                                                                              (get-buffer "TestNet"))))))
          (with-current-buffer "TestNet"
            (erc-cmd-JOIN "#lisp")
            (erc-cmd-JOIN "#emacs"))
          (should (lispm-store-test--wait (lambda () (and (get-buffer "#lisp") (get-buffer "#emacs")
                                                          (with-current-buffer "#lisp" erc-channel-topic)
                                                          (with-current-buffer "#emacs" erc-channel-topic)))))
          (lispm-store-test--irc-say ":bob!b@example.org PRIVMSG #emacs :lispmachines, anyone?")
          (lispm-store-test--irc-say ":alice!a@example.org PRIVMSG #lisp :lispm: have you tried the agents?")
          (lispm-store-test--irc-say ":bob!b@example.org PRIVMSG #lisp :\1ACTION waves\1")
          (lispm-store-test--irc-say ":carol!c@example.org JOIN #lisp")
          (lispm-store-test--irc-say ":alice!a@example.org PRIVMSG lispm :a word in private")
          (should (lispm-store-test--wait (lambda () (get-buffer "alice"))))
          (let ((list (lispm-store-test--call "irc_conversations")))
            (should (string-match-p "\\`TestNet: connected as lispm\n" list))
            (should (string-match-p "^  #lisp: [0-9]+ unread, naming the user; 4 people; topic: Lisp machines, then and now$"
                                    list))
            (should (string-match-p "^  #emacs: [0-9]+ unread; 3 people; topic: " list))
            (should (string-match-p "^  alice (private): 1 unread, naming the user$" list)))
          ;; What people said; and with all, the rest.
          (let ((read (lispm-store-test--call "irc_read" "#lisp" nil nil nil)))
            (should (string-match-p "\\`#lisp on TestNet, messages [0-9]+ to [0-9]+:\n" read))
            (should (string-match-p "^[0-9]+\\. [-0-9]+ [:0-9]+ <alice> lispm: have you tried the agents\\?\n[0-9]+\\. .* \\* bob waves\\'"
                                    read))
            (should-not (string-match-p "carol" read)))
          (let ((read (lispm-store-test--call "irc_read" "#lisp" nil nil t)))
            (should (string-match-p "carol .*has joined channel #lisp" read))
            (should (string-match-p "Topic for #lisp: Lisp machines" read)))
          (let* ((last (lispm-store-test--call "irc_read" "#lisp" 1 nil nil))
                 (before (and (string-match "read on with before \\([0-9]+\\)\\]\\'" last)
                              (string-to-number (match-string 1 last)))))
            (should (string-match-p "\n[0-9]+\\. .*\\* bob waves\n" last))
            (should before)
            (should (string-match-p "<alice> lispm: have you tried\\(?:.\\|\n\\)*\\'"
                                    (lispm-store-test--call "irc_read" "#lisp" 1 before nil))))
          (should (string-match-p "<alice> a word in private" (lispm-store-test--call "irc_read" "alice" nil nil nil)))
          (should (string-match-p "\\`TestNet, the network TestNet's own buffer, .*\n\\(?:.\\|\n\\)*End of MOTD"
                                  (lispm-store-test--call "irc_read" "TestNet" nil nil t)))
          (should-error (lispm-store-test--call "irc_read" "#nowhere" nil nil nil))
          ;; Newest first, in every conversation or in one.
          (let ((found (lispm-store-test--call "irc_search" "LISPM\\|private" nil nil)))
            (should (string-match-p "\\`alice [0-9]+\\. .*<alice> a word in private\n#lisp [0-9]+\\. .*<alice> lispm: have"
                                    found)))
          (should-not (string-match-p "private" (lispm-store-test--call "irc_search" "private\\|agents" "#lisp" nil)))
          (should (string-match-p "\\`Nothing said" (lispm-store-test--call "irc_search" "emacs" "#lisp" nil)))
          ;; Sending asks the user every time, and sends lines as text.
          (let ((tool (lispm-get-tool "irc_send")))
            (should (eq (lispm-tool-permission tool) 'chat))
            (should (lispm-tool-always-ask tool))
            (should (equal (lispm-tool-preview-text tool '((conversation . "#lisp") (text . "Hello\n\nthere")))
                           "To #lisp on TestNet:\n\nHello\nthere")))
          (should (equal (lispm-store-test--call "irc_send" "#lisp" "Yes, they read along.\n/quit" nil)
                         "Sent 2 messages to #lisp on TestNet."))
          (should (funcall heard "PRIVMSG #lisp :Yes, they read along."))
          (should (funcall heard "PRIVMSG #lisp :/quit"))
          (should (lispm-store-test--wait
                   (lambda () (string-match-p "<lispm> Yes, they read along\\."
                                              (lispm-store-test--call "irc_read" "#lisp" nil nil nil)))))
          (should (equal (lispm-store-test--call "irc_send" "dave" "Hello, Dave." nil)
                         "Sent 1 message to dave on TestNet."))
          (should (funcall heard "PRIVMSG dave :Hello, Dave."))
          (should (get-buffer "dave"))
          (should-error (lispm-store-test--call "irc_send" "#elsewhere" "Hi" nil))
          (should-error (lispm-store-test--call "irc_send" "TestNet" "Hi" nil))
          (should-error (lispm-store-test--call "irc_send" "#lisp" "\n \n" nil))
          (should-not (member "JOIN #elsewhere" lispm-store-test--irc-heard)))
      (let ((kill-buffer-query-functions nil))
        (mapc #'kill-buffer (erc-buffer-list)))
      (delete-process server))))

(defun lispm-store-test--slack-answer (url params)
  "What a fake Slack answers to a request to URL with PARAMS, an alist."
  (let ((channel (alist-get "channel" params nil nil #'equal)))
    (pcase url
      ("https://slack.com/api/conversations.history"
       (if (equal channel "C1")
           (let ((all '((:type "message" :user "U2" :text "Lunch at noon?" :ts "1792578870.000300")
                        (:type "message" :user "U1" :text "<@U0> the build is green" :ts "1792578860.000200"
                         :thread_ts "1792578860.000200" :reply_count 2
                         :files ((:id "F1" :name "build.log" :title "build.log")))
                        (:type "message" :user "U2" :text "Morning, all" :ts "1792578850.000100")))
                 (latest (alist-get "latest" params nil nil #'equal))
                 (limit (string-to-number (alist-get "limit" params "100" nil #'equal))))
             (let* ((older (seq-filter (lambda (message) (or (null latest) (string-lessp (plist-get message :ts) latest)))
                                       all))
                    (page (seq-take older limit)))
               (list :ok t :messages (copy-tree page) :has_more (if (< (length page) (length older)) t :json-false))))
         (list :ok :json-false :error "channel_not_found")))
      ("https://slack.com/api/conversations.replies"
       (list :ok t :has_more :json-false
             :messages (copy-tree '((:type "message" :user "U1" :text "<@U0> the build is green" :ts "1792578860.000200"
                                     :thread_ts "1792578860.000200" :reply_count 2)
                                    (:type "message" :user "U2" :text "Ship it" :ts "1792578861.000100"
                                     :thread_ts "1792578860.000200")
                                    (:type "message" :user "U0" :text "Shipping" :ts "1792578862.000100"
                                     :thread_ts "1792578860.000200")))))
      ("https://slack.com/api/search.messages"
       (list :ok t :messages (list :total 1
                                   :matches (copy-tree '((:channel (:id "C1" :name "general") :user "U2" :username "bob"
                                                          :ts "1792578870.000300" :text "Lunch at noon?"))))))
      ("https://slack.com/api/chat.postMessage" (list :ok t))
      (_ (list :ok :json-false :error (format "unexpected %s" url))))))

(ert-deftest lispm-store-test-chat-slack ()
  "The Slack skill lists emacs-slack's conversations, reads, searches and
sends to them, against a fake Slack."
  (lispm-store-test--load-skills)
  (let ((slack-teams-by-token (make-hash-table :test 'equal))
        (team (slack-create-team (list :id "T1" :name "Lab" :token "xoxp-test" :self-id "U0")))
        asked)
    (puthash "xoxp-test" team slack-teams-by-token)
    (slack-team-set-users team (copy-tree '((:id "U0" :name "me" :profile (:display_name_normalized "me"))
                                            (:id "U1" :name "alice" :profile (:display_name_normalized "alice"))
                                            (:id "U2" :name "bob" :profile (:display_name_normalized "bob")))))
    (dolist (payload '((:id "C1" :name "general" :is_channel t :is_member t :topic (:value "Builds and lunch"))
                       (:id "C2" :name "random" :is_channel t :is_member :json-false)))
      (puthash (plist-get payload :id) (slack-room-create (copy-tree payload) 'slack-channel) (oref team channels)))
    (puthash "D1" (slack-room-create (list :id "D1" :user "U1" :is_im t) 'slack-im) (oref team ims))
    (oset team counts (slack-create-counts
                       (copy-tree '(:threads (:has_unreads :json-false :mention_count 0)
                                    :channels ((:id "C1" :has_unreads t :mention_count 1 :latest "1792578870.000300")
                                               (:id "C2" :has_unreads t :mention_count 0 :latest "1792578000.000100"))
                                    :mpims ()
                                    :ims ((:id "D1" :has_unreads :json-false :mention_count 0
                                           :latest "1792578000.000100"))))))
    (cl-letf (((symbol-function 'slack-request)
               (lambda (request &rest _)
                 (let ((params (or (oref request params)
                                   (json-parse-string (oref request data) :object-type 'alist :array-type 'list))))
                   (push (cons (oref request url) params) asked)
                   (run-at-time 0 nil (oref request success)
                                :data (lispm-store-test--slack-answer
                                       (oref request url)
                                       (mapcar (lambda (entry) (cons (format "%s" (car entry)) (cdr entry))) params))))
                 request)))
      (let ((list (lispm-store-test--call "slack_conversations" nil)))
        (should (string-match-p "\\`Lab: not connected\n  #general: unread, 1 mentioning the user; topic: Builds and lunch\n  alice (direct)\\'"
                                list)))
      (should (string-match-p "\\`Lab: not connected\n  #general: unread" (lispm-store-test--call "slack_conversations" t)))
      ;; Oldest first, with what is attached and replied.
      (let ((read (lispm-store-test--call-async "slack_read" "#general" nil nil nil nil)))
        (should (string-match-p "\\`#general in Lab:\n1792578850\\.000100  [-0-9]+ [:0-9]+  bob: Morning, all\n" read))
        (should (string-match-p "^1792578860\\.000200  .*  alice: @me the build is green \\[files: build\\.log\\] \\[2 replies: read them with thread 1792578860\\.000200\\]$"
                                read))
        (should (string-match-p "bob: Lunch at noon\\?\\'" read)))
      (let ((read (lispm-store-test--call-async "slack_read" "general" "Lab" 1 "1792578870.000300" nil)))
        (should (string-match-p "alice: @me the build is green.*\n\n\\[earlier messages: read on with before 1792578860\\.000200\\]\\'"
                                read))
        (should-not (string-match-p "Lunch" read)))
      (let ((read (lispm-store-test--call-async "slack_read" "#general" nil nil nil "1792578860.000200")))
        (should (string-match-p "\\`#general in Lab, the thread of 1792578860\\.000200:\n" read))
        (should (string-match-p "bob: Ship it\n.*me: Shipping\\'" read))
        (should-not (string-match-p "replies" read)))
      (should-error (lispm-store-test--call-async "slack_read" "#nowhere" nil nil nil nil))
      (should (string-match-p "\\`#general  1792578870\\.000300  .*  bob: Lunch at noon\\?\\'"
                              (lispm-store-test--call-async "slack_search" "lunch in:#general" nil nil)))
      (should (equal (alist-get "query" (alist-get "https://slack.com/api/search.messages" asked nil nil #'equal)
                                nil nil #'equal)
                     "lunch in:#general"))
      ;; Sending asks the user every time, and never joins a channel.
      (let ((tool (lispm-get-tool "slack_send")))
        (should (eq (lispm-tool-permission tool) 'chat))
        (should (lispm-tool-always-ask tool))
        (should (equal (lispm-tool-preview-text tool '((conversation . "#general") (text . "On my way")))
                       "To #general in Lab:\n\nOn my way")))
      (should (equal (lispm-store-test--call-async "slack_send" "#general" "On my way" nil "1792578870.000300")
                     "Sent to #general in Lab, in the thread of 1792578870.000300."))
      (let ((posted (alist-get "https://slack.com/api/chat.postMessage" asked nil nil #'equal)))
        (should (equal (alist-get 'channel posted) "C1"))
        (should (equal (alist-get 'thread_ts posted) "1792578870.000300")))
      (should (equal (lispm-store-test--call-async "slack_send" "alice" "Thanks!" nil nil)
                     "Sent to alice in Lab."))
      (should-error (lispm-store-test--call-async "slack_send" "#random" "Hi" nil nil))
      (should-not (seq-some (lambda (call) (string-match-p "join" (car call))) asked)))))

(defconst lispm-store-test--telegram-messages
  '((:@type "message" :id 3145728 :chat_id -200 :date 1792578870
     :sender_id (:@type "messageSenderUser" :user_id 12)
     :reply_to (:@type "messageReplyToMessage" :chat_id -200 :message_id 2097152)
     :content (:@type "messageText" :text (:@type "formattedText" :text "Lunch at noon?" :entities [])))
    (:@type "message" :id 2097152 :chat_id -200 :date 1792578860
     :sender_id (:@type "messageSenderUser" :user_id 11)
     :content (:@type "messagePhoto" :photo (:@type "photo" :sizes [])
               :caption (:@type "formattedText" :text "The build is green" :entities [])))
    (:@type "message" :id 1048576 :chat_id -200 :date 1792578850
     :sender_id (:@type "messageSenderUser" :user_id 12)
     :content (:@type "messageText" :text (:@type "formattedText" :text "Morning, all" :entities []))))
  "The messages of the fake Telegram's group, newest first.")

(defun lispm-store-test--telegram-answer (request)
  "What a fake TDLib answers to REQUEST, a plist."
  (pcase (plist-get request :@type)
    ("getUser"
     (pcase (plist-get request :user_id)
       (11 (list :@type "user" :id 11 :first_name "Ada" :last_name "Lovelace" :type '(:@type "userTypeRegular")))
       (12 (list :@type "user" :id 12 :first_name "Bob" :last_name "" :type '(:@type "userTypeRegular")))))
    ("getChatHistory"
     ;; The messages before the one given, or from the last; two at a
     ;; time, as TDLib gives fewer than asked when they are not local.
     (let* ((from (plist-get request :from_message_id))
            (messages (seq-drop-while (lambda (message) (and (> from 0) (>= (plist-get message :id) from)))
                                      (if (equal (plist-get request :chat_id) -200) lispm-store-test--telegram-messages))))
       (list :@type "messages" :total_count (length messages)
             :messages (vconcat (copy-tree (seq-take messages (min 2 (plist-get request :limit))))))))
    ("searchMessages"
     (list :@type "foundMessages" :total_count 1
           :messages (vconcat (copy-tree (seq-take lispm-store-test--telegram-messages 1)))))
    ("searchChatMessages"
     (list :@type "foundChatMessages" :total_count 0 :messages []))
    ("sendMessage"
     (list :@type "message" :id 4194304 :chat_id (plist-get request :chat_id)))))

(ert-deftest lispm-store-test-chat-telegram ()
  "The Telegram skill lists Telega's chats, reads, searches and sends to
them, against a fake telega-server."
  (lispm-store-test--load-skills)
  (let ((telega--chats (make-hash-table :test #'eq))
        (telega--info (mapcar (lambda (type) (cons type (make-hash-table :test #'eq)))
                              '(user secretChat basicGroup supergroup)))
        (telega--me-id 10)
        (telega--auth-state "Ready")
        asked)
    (dolist (chat `((:@type "chat" :id 101 :title "Ada Lovelace" :type (:@type "chatTypePrivate" :user_id 11)
                     :positions [(:@type "chatPosition" :list (:@type "chatListMain") :order "300")]
                     :unread_count 2 :unread_mention_count 0)
                    (:@type "chat" :id -200 :title "Lisp Hackers"
                     :type (:@type "chatTypeSupergroup" :supergroup_id 20)
                     :positions [(:@type "chatPosition" :list (:@type "chatListMain") :order "500")]
                     :unread_count 5 :unread_mention_count 1)
                    (:@type "chat" :id -300 :title "Old News"
                     :type (:@type "chatTypeSupergroup" :supergroup_id 30 :is_channel t)
                     :positions [(:@type "chatPosition" :list (:@type "chatListArchive") :order "100")]
                     :unread_count 0 :unread_mention_count 0)))
      (puthash (plist-get chat :id) (copy-tree chat t) telega--chats))
    (cl-letf (((symbol-function 'telega-server-live-p) #'always)
              ((symbol-function 'telega-server--call)
               (lambda (request &optional callback _command)
                 (push request asked)
                 (let ((answer (lispm-store-test--telegram-answer request)))
                   (if callback (funcall callback answer) answer)))))
      (should (equal (lispm-store-test--call "telegram_chats" nil)
                     (concat "Lisp Hackers (group, id -200): 5 unread, 1 mentioning the user\n"
                             "Ada Lovelace (private, id 101): 2 unread")))
      (should (string-match-p "\\`Lisp Hackers .*\nAda Lovelace .*\\'" (lispm-store-test--call "telegram_chats" t)))
      ;; Oldest first, asking TDLib until there are enough.
      (let ((read (lispm-store-test--call "telegram_read" "lisp hackers" nil nil)))
        (should (string-match-p "\\`Lisp Hackers (group, id -200):\n1048576  [-0-9]+ [:0-9]+  Bob: Morning, all\n" read))
        (should (string-match-p "^2097152  .*  Ada Lovelace: \\[photo\\] The build is green$" read))
        (should (string-match-p "^3145728  .*  Bob: Lunch at noon\\? \\[replying to 2097152\\]\\'" read)))
      (let ((read (lispm-store-test--call "telegram_read" "-200" 1 3145728)))
        (should (string-match-p "\n2097152  .*The build is green\n\n\\[earlier messages: read on with before 2097152\\]\\'"
                                read))
        (should-not (string-match-p "Lunch" read)))
      (should-error (lispm-store-test--call "telegram_read" "Old Times" nil nil))
      (should (string-match-p "\\`Lisp Hackers  3145728  .*  Bob: Lunch at noon\\?"
                              (lispm-store-test--call "telegram_search" "lunch" nil nil)))
      (should (string-match-p "\\`No message in Ada Lovelace matches \"lunch\""
                              (lispm-store-test--call "telegram_search" "lunch" "Ada Lovelace" nil)))
      ;; Sending asks the user every time.
      (let ((tool (lispm-get-tool "telegram_send")))
        (should (eq (lispm-tool-permission tool) 'chat))
        (should (lispm-tool-always-ask tool))
        (should (equal (lispm-tool-preview-text tool '((chat . "Lisp Hackers") (text . "On my way") (reply_to . 3145728)))
                       "To Lisp Hackers (group, id -200), replying to 3145728:\n\nOn my way")))
      (should (equal (lispm-store-test--call "telegram_send" "Lisp Hackers" "On my way" 3145728)
                     "Sent to Lisp Hackers, replying to 3145728."))
      (let ((sent (seq-find (lambda (request) (equal (plist-get request :@type) "sendMessage")) asked)))
        (should (equal (plist-get sent :chat_id) -200))
        (should (equal (plist-get (plist-get sent :reply_to) :message_id) 3145728))
        (should (equal (plist-get (plist-get (plist-get sent :input_message_content) :text) :text) "On my way")))
      (should-error (lispm-store-test--call "telegram_send" "Lisp Hackers" "  " nil))
      (let ((telega--auth-state "WaitPhoneNumber"))
        (should-error (lispm-store-test--call "telegram_chats" nil))))))

(provide 'lispm-store-test)
;;; lispm-store-test.el ends here
