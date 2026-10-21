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

(defun lispm-store-test--install ()
  "Install every app's and extension's package as LispM Desktop does, once.
Each in an Emacs of its own, as installing loads what it compiles.
A package from git may require a newer version of a package Emacs
has built in, such as Compat: Emacs 30.1's package-vc leaves that
unmet, as it compares no versions (fixed in 30.2).  Then the newer
one is installed from the archives, and the package compiled again
in a new Emacs, which loads it rather than the built-in one."
  (unless lispm-store-test--installed
    (pcase-dolist (`(,_id . ,item) (append (lispm-store-test--of-kind 'app)
                                           (lispm-store-test--of-kind 'extension)))
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
  "Return LispM Desktop's lisp/, which must be on the load path."
  (file-name-directory (or (locate-library "lispm-desktop-ai")
                           (error "LispM Desktop's lisp/ is not on the load path"))))

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
                                 `(progn (add-to-list 'load-path ,(lispm-store-test--desktop))
                                         (featurep (require ',feature))))))
                     (list id t))))))

(ert-deftest lispm-store-test-needs-name-the-apps-own ()
  "The commands and options an app's needs name are its own: commands
once its package is installed, options once it is loaded.  In a new
Emacs, as after a restart."
  (lispm-store-test--install)
  (pcase-dolist (`(,id . ,item) (lispm-store-test--of-kind 'app))
    (let ((package (plist-get item :package)))
      (dolist (need (plist-get item :needs))
        (let ((properties (cddr need)))
          (dolist (command (plist-get properties :commands))
            (should (equal (list id command (lispm-store-test--emacs `(commandp ',command)))
                           (list id command t))))
          (dolist (variable (plist-get properties :variables))
            (should (equal (list id variable
                                 (lispm-store-test--emacs
                                  `(progn (require ',(if (consp package) (car package) package))
                                          (boundp ',variable))))
                           (list id variable t)))))))))

(ert-deftest lispm-store-test-extensions-load ()
  "Each extension's package, once installed, loads beside LispM Desktop and
provides its feature.  In a new Emacs, with LispM Desktop's lisp/ on its
load path, as it is in LispM Desktop."
  (lispm-store-test--install)
  (let ((desktop (lispm-store-test--desktop)))
    (pcase-dolist (`(,id . ,item) (lispm-store-test--of-kind 'extension))
      (let ((feature (plist-get item :feature)))
        (should (equal (list id (lispm-store-test--emacs
                                 `(progn (add-to-list 'load-path ,desktop)
                                         (featurep (require ',feature)))))
                       (list id t)))))))

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

(provide 'lispm-store-test)
;;; lispm-store-test.el ends here
