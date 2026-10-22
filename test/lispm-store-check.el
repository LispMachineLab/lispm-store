;;; lispm-store-check.el --- Check the LispM Store's catalog  -*- lexical-binding: t; -*-

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

;; `make check': reads catalog.eld as LispM Desktop does, as data, and
;; checks it and the files it names against the format README.org
;; describes.  Its applications and extensions are checked by LispM
;; Desktop's own rules, lispm-desktop-catalog.el, the ones its App Store
;; reads the catalog with: an error there keeps an item out of the App
;; Store, a warning leaves it listed short of what it should say, and
;; either fails the check.  The rest is this store's: its icons drawn as
;; pixel art, its files all used, roles' and skills' files.  It needs no
;; network, only Emacs and LispM Desktop's lisp/:
;;
;;   emacs -Q --batch -L ../lispm-desktop/lisp -l test/lispm-store-check.el -f lispm-store-check
;;
;; Every problem is reported, then Emacs exits non-zero if there was one.

;;; Code:

(require 'cl-lib)
(require 'subr-x)
(require 'org-src)

(eval-and-compile
  (unless (require 'lispm-desktop-catalog nil t)
    (error "LispM Desktop's lisp/ is not on the load path: make check LISPM_DESKTOP=DIR")))

(defconst lispm-store-check-root
  (file-name-directory (directory-file-name (file-name-directory (or load-file-name buffer-file-name))))
  "The store's checkout.")

(defconst lispm-store-check-keys
  '((role :required (:kind :name :description :file) :optional (:requires))
    (skill :required (:kind :name :description :file) :optional (:requires)))
  "The properties of an item of each kind LispM Agent's, not the App
Store's; those of an app or an extension are `lispm-desktop-catalog-properties'.")

(defconst lispm-store-check-forbidden '(:make :shell-command)
  "Properties no part of the catalog may hold: they would run commands.")

(defconst lispm-store-check-role-keywords '("title" "description" "tools" "effort")
  "The keywords a role file may have; title and description it must.")

(defconst lispm-store-check-efforts '("low" "medium" "high" "xhigh" "max")
  "The effort levels a role may ask for.")

(defvar lispm-store-check--problems nil
  "The problems found, latest first.")

(defun lispm-store-check--problem (format-string &rest args)
  "Report a problem, FORMAT-STRING formatted with ARGS."
  (push (apply #'format format-string args) lispm-store-check--problems))

(defun lispm-store-check--file (name)
  "The file NAME of the store."
  (expand-file-name name lispm-store-check-root))

(defun lispm-store-check--text (name)
  "The text of the store's file NAME."
  (with-temp-buffer
    (insert-file-contents (lispm-store-check--file name))
    (buffer-string)))

;;;; The catalog

(defun lispm-store-check--read-catalog ()
  "The form catalog.eld holds, or nil after reporting why there is none."
  (condition-case err
      (with-temp-buffer
        (insert-file-contents (lispm-store-check--file "catalog.eld"))
        (unless (looking-at-p ";; -\\*- lisp-data -\\*-$")
          (lispm-store-check--problem "catalog.eld: its first line is not ;; -*- lisp-data -*-"))
        (with-syntax-table lisp-data-mode-syntax-table
          (let ((catalog (read (current-buffer))))
            (forward-comment (buffer-size))
            (unless (eobp)
              (lispm-store-check--problem "catalog.eld: there is more than one form"))
            catalog)))
    (error (lispm-store-check--problem "catalog.eld does not read: %s" (error-message-string err))
           nil)))

(defun lispm-store-check--plist-p (plist where)
  "Non-nil if PLIST is a property list of keywords, each once; else report it at WHERE."
  (cond ((not (and (proper-list-p plist) (cl-evenp (length plist))))
         (lispm-store-check--problem "%s: not a property list" where)
         nil)
        (t (let (seen (ok t))
             (cl-loop for (key) on plist by #'cddr
                      do (cond ((not (keywordp key))
                                (lispm-store-check--problem "%s: %S is not a keyword" where key)
                                (setq ok nil))
                               ((memq key seen)
                                (lispm-store-check--problem "%s: %s is given twice" where key)
                                (setq ok nil))
                               (t (push key seen))))
             ok))))

(defun lispm-store-check--forbidden (tree)
  "Report every property of `lispm-store-check-forbidden' anywhere in TREE."
  (cond ((memq tree lispm-store-check-forbidden)
         (lispm-store-check--problem "catalog.eld holds %s: the store runs no build commands" tree))
        ((consp tree)
         (lispm-store-check--forbidden (car tree))
         (lispm-store-check--forbidden (cdr tree)))))

(defun lispm-store-check--id-p (object)
  "Non-nil if OBJECT can name an item, an icon or a package."
  (and (symbolp object) object (not (keywordp object)) (not (eq object t))
       (string-match-p "\\`[a-z0-9][a-z0-9-]*\\'" (symbol-name object))))

(defun lispm-store-check--line-p (object)
  "Non-nil if OBJECT is a string of one line, trimmed and not empty."
  (and (stringp object) (not (string-empty-p object))
       (not (string-match-p "\n" object)) (equal object (string-trim object))))

;;;; Applications

(defun lispm-store-check--svg (name size)
  "Check icons/NAME.svg, or icons/NAME-SIZE.svg, a pixel-art icon SIZE pixels square."
  (let ((file (format "icons/%s%s.svg" name (if (= size 16) "" (format "-%d" size)))))
    (if (not (file-regular-p (lispm-store-check--file file)))
        (lispm-store-check--problem "%s: missing" file)
      (let ((svg (lispm-store-check--text file)))
        (unless (string-match-p
                 (format "\\`<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\" shape-rendering=\"crispEdges\">\n"
                         size size size size)
                 svg)
          (lispm-store-check--problem "%s: does not start as a %dx%d pixel-art SVG does" file size size))
        ;; Rectangles of a colour and nothing else: no scripts, no links.
        (let ((rest (replace-regexp-in-string
                     "<rect x=\"[0-9]+\" y=\"[0-9]+\" width=\"[0-9]+\" height=\"[0-9]+\" fill=\"#[0-9A-F]\\{6\\}\"/>"
                     "" (replace-regexp-in-string "\\`<svg [^>]*>\\|</svg>\n*\\'" "" svg))))
          (unless (string-blank-p rest)
            (lispm-store-check--problem "%s: holds more than rect elements: %s" file
                                        (truncate-string-to-width (string-trim rest) 60))))))
    file))

(defun lispm-store-check--app-or-extension (id item)
  "Check the app or extension ID, whose properties are ITEM, by LispM
Desktop's rules, then what only this store asks: an app built into Emacs
is there in emacs -Q, and its icons are drawn as pixel art.  Return the
files it uses."
  (pcase-dolist (`(,severity . ,text) (lispm-desktop-catalog-item-problems (cons id item)))
    (lispm-store-check--problem "%s: %s%s" id text
                                (if (eq severity 'error) " (LispM Desktop leaves it out)" "")))
  (let ((command (plist-get item :command))
        (feature (plist-get item :feature))
        (icon (plist-get item :icon)))
    (when (and (eq (plist-get item :kind) 'app) (null (plist-get item :package)))
      ;; Built into Emacs: it must be there in emacs -Q.
      (cond ((and command (symbolp command) (not (commandp command)))
             (lispm-store-check--problem "%s: %s is not a command of Emacs" id command))
            ((and (not command) feature (symbolp feature) (not (locate-library (symbol-name feature))))
             (lispm-store-check--problem "%s: %s is not a library of Emacs" id feature))))
    (when (and (stringp icon) (string-match-p "\\`[a-z0-9][a-z0-9-]*\\'" icon))
      (list (lispm-store-check--svg icon 16) (lispm-store-check--svg icon 32)))))

;;;; Roles and skills

(defun lispm-store-check--keywords (text)
  "The #+ keywords at the start of the org TEXT: an alist (KEY . VALUE), and the body.
Returns (KEYWORDS . BODY)."
  (with-temp-buffer
    (insert text)
    (goto-char (point-min))
    (let (keywords)
      (while (looking-at "#\\+\\([A-Za-z_]+\\):[ \t]*\\(.*?\\)[ \t]*$")
        (push (cons (downcase (match-string 1)) (match-string 2)) keywords)
        (forward-line 1))
      (cons (nreverse keywords) (buffer-substring-no-properties (point) (point-max))))))

(defun lispm-store-check--role (id item)
  "Check the role ID, whose properties are ITEM; return the files it uses."
  (let ((file (plist-get item :file)))
    (cond ((not (equal file (format "roles/%s.org" id)))
           (lispm-store-check--problem "%s: a role's :file is \"roles/%s.org\"" id id)
           nil)
          ((not (file-regular-p (lispm-store-check--file file)))
           (lispm-store-check--problem "%s: missing" file)
           nil)
          (t
           (pcase-let ((`(,keywords . ,body) (lispm-store-check--keywords (lispm-store-check--text file))))
             (dolist (keyword keywords)
               (unless (member (car keyword) lispm-store-check-role-keywords)
                 (lispm-store-check--problem "%s: #+%s: is not a role's keyword (only %s)" file (car keyword)
                                             (string-join lispm-store-check-role-keywords ", "))))
             (dolist (key '("title" "description"))
               (unless (lispm-store-check--line-p (cdr (assoc key keywords)))
                 (lispm-store-check--problem "%s: needs #+%s:" file key)))
             (when-let* ((tools (assoc "tools" keywords)))
               (let ((value (condition-case nil
                                (let ((read (read-from-string (cdr tools))))
                                  (if (string-blank-p (substring (cdr tools) (cdr read))) (car read) 'unreadable))
                              (error 'unreadable))))
                 (unless (or (eq value t)
                             (and (proper-list-p value) value
                                  (cl-every (lambda (tool)
                                              (and (symbolp tool)
                                                   (string-match-p "\\`[a-z][a-z0-9_]*\\*?\\'" (symbol-name tool))))
                                            value)))
                   (lispm-store-check--problem "%s: #+tools: is t or a list of tool names" file))))
             (when-let* ((effort (assoc "effort" keywords)))
               (unless (member (cdr effort) lispm-store-check-efforts)
                 (lispm-store-check--problem "%s: #+effort: is one of %s" file
                                             (string-join lispm-store-check-efforts ", "))))
             (when (string-blank-p body)
               (lispm-store-check--problem "%s: has no instructions" file)))
           (list file)))))

(defun lispm-store-check--blocks (text)
  "The code of the source blocks of TEXT marked :lispm load, as LispM finds them."
  (with-temp-buffer
    (insert text)
    (goto-char (point-min))
    (let ((case-fold-search t) blocks)
      (while (re-search-forward "^[ \t]*#\\+begin_src[ \t]+emacs-lisp\\([^\n]*\\)\n" nil t)
        (let ((args (match-string 1))
              (start (point))
              (line (line-number-at-pos)))
          (if (not (re-search-forward "^[ \t]*#\\+end_src" nil t))
              (push (list line nil) blocks)
            (when (string-match-p ":lispm[ \t]+load" args)
              (push (list line (org-unescape-code-in-string
                                (buffer-substring-no-properties start (match-beginning 0))))
                    blocks)))))
      (nreverse blocks))))

(defun lispm-store-check--code (file line code)
  "Check that CODE, the block of FILE starting at LINE, reads whole."
  (if (null code)
      (lispm-store-check--problem "%s:%d: the block is not closed with #+end_src" file line)
    (with-temp-buffer
      (with-syntax-table emacs-lisp-mode-syntax-table
        (insert code)
        (goto-char (point-min))
        (let ((at 1))
          (condition-case err
              (while (progn (forward-comment (buffer-size)) (not (eobp)))
                (setq at (line-number-at-pos))
                (read (current-buffer)))
            (end-of-file
             (lispm-store-check--problem "%s:%d: the code does not read: the form at its line %d is not closed"
                                         file line at))
            (error
             (lispm-store-check--problem "%s:%d: the code does not read, at its line %d: %s"
                                         file line (line-number-at-pos) (error-message-string err)))))))))

(defun lispm-store-check--skill (id item)
  "Check the skill ID, whose properties are ITEM; return the files it uses."
  (let* ((file (plist-get item :file))
         (org (cond ((equal file (format "skills/%s.org" id)) file)
                    ((equal file (format "skills/%s/" id)) (concat file "SKILL.org")))))
    (cond ((null org)
           (lispm-store-check--problem "%s: a skill's :file is \"skills/%s.org\" or \"skills/%s/\"" id id id)
           nil)
          ((not (file-regular-p (lispm-store-check--file org)))
           (lispm-store-check--problem "%s: missing" org)
           nil)
          (t
           (let* ((text (lispm-store-check--text org))
                  (keywords (car (lispm-store-check--keywords text)))
                  (blocks (lispm-store-check--blocks text)))
             (dolist (key '("title" "description"))
               (unless (lispm-store-check--line-p (cdr (assoc key keywords)))
                 (lispm-store-check--problem "%s: needs #+%s:" org key)))
             (pcase-dolist (`(,line ,code) blocks)
               (lispm-store-check--code org line code)))
           (if (string-suffix-p "/" file)
               (directory-files-recursively (lispm-store-check--file file) "")
             (list org))))))

;;;; Everything

(defun lispm-store-check--requires (items)
  "Check the :requires of ITEMS, an alist (ID . PROPERTIES): known items, no cycle."
  (pcase-dolist (`(,id . ,item) items)
    (let ((requires (plist-get item :requires)))
      (when (plist-member item :requires)
        (if (not (and (proper-list-p requires) requires))
            (lispm-store-check--problem "%s: :requires is a list of item IDs" id)
          (dolist (other requires)
            (cond ((eq other id) (lispm-store-check--problem "%s: requires itself" id))
                  ((not (assq other items))
                   (lispm-store-check--problem "%s: requires %S, which is not in the catalog" id other))
                  ;; LispM Desktop installs apps and extensions only.
                  ((and (memq (plist-get item :kind) '(app extension))
                        (not (memq (plist-get (cdr (assq other items)) :kind) '(app extension))))
                   (lispm-store-check--problem "%s: requires %S, which the App Store does not install"
                                               id other))))))))
  ;; A cycle would leave no order to install them in.
  (let (done)
    (cl-labels ((visit (id path)
                  (cond ((memq id path)
                         (lispm-store-check--problem "%s: its :requires go round in a circle" id))
                        ((not (memq id done))
                         (dolist (other (plist-get (cdr (assq id items)) :requires))
                           (when (and (symbolp other) (assq other items))
                             (visit other (cons id path))))
                         (push id done)))))
      (dolist (item items)
        (visit (car item) nil)))))

(defun lispm-store-check--unused (used)
  "Report files of icons/, roles/ and skills/ that USED, the files items use, does not hold."
  (dolist (directory '("icons" "roles" "skills"))
    (dolist (file (and (file-directory-p (lispm-store-check--file directory))
                       (directory-files-recursively (lispm-store-check--file directory) "")))
      (let ((name (file-relative-name file lispm-store-check-root)))
        (unless (member name used)
          (lispm-store-check--problem "%s: no item uses it" name))))))

(defun lispm-store-check-catalog ()
  "Check catalog.eld and the files it names; return the problems."
  (setq lispm-store-check--problems nil)
  (let ((catalog (lispm-store-check--read-catalog)) items used)
    (when catalog
      (lispm-store-check--forbidden catalog)
      (when (lispm-store-check--plist-p catalog "catalog.eld")
        (unless (equal (sort (cl-loop for (key) on catalog by #'cddr collect key) #'string<)
                       '(:items :name))
          (lispm-store-check--problem "catalog.eld: the catalog is (:name STRING :items LIST)"))
        (unless (lispm-store-check--line-p (plist-get catalog :name))
          (lispm-store-check--problem "catalog.eld: :name is a string"))
        (let ((list (plist-get catalog :items)))
          (unless (and (proper-list-p list) list)
            (lispm-store-check--problem "catalog.eld: :items is a list of items"))
          (dolist (entry (and (proper-list-p list) list))
            (let ((id (car-safe entry)) (item (cdr-safe entry)))
              (cond ((not (lispm-store-check--id-p id))
                     (lispm-store-check--problem "catalog.eld: %S: an item is (ID . PROPERTIES), ID a lower-case symbol"
                                                 (if (consp entry) id entry)))
                    ((assq id items)
                     (lispm-store-check--problem "%s: two items have this ID" id))
                    ((lispm-store-check--plist-p item (symbol-name id))
                     (push (cons id item) items)
                     (let* ((kind (plist-get item :kind))
                            (keys (cdr (assq kind lispm-store-check-keys))))
                       (cond
                        ((memq kind lispm-desktop-catalog-kinds)
                         (setq used (append (lispm-store-check--app-or-extension id item) used)))
                        ((null keys)
                         (lispm-store-check--problem "%s: :kind is app, extension, role or skill" id))
                        (t
                         (dolist (key (plist-get keys :required))
                           (unless (plist-member item key)
                             (lispm-store-check--problem "%s: needs %s" id key)))
                         (cl-loop for (key) on item by #'cddr
                                  unless (memq key (append (plist-get keys :required) (plist-get keys :optional)))
                                  do (lispm-store-check--problem "%s: %s is not a property of a %s" id key kind))
                         (dolist (key '(:name :description))
                           (unless (lispm-store-check--line-p (plist-get item key))
                             (lispm-store-check--problem "%s: %s is a string of one line" id key)))
                         (setq used (append (pcase kind
                                              ('role (lispm-store-check--role id item))
                                              ('skill (lispm-store-check--skill id item)))
                                            used)))))))))
          (setq items (nreverse items))
          (lispm-store-check--requires items)
          (lispm-store-check--unused (mapcar (lambda (file)
                                               (file-relative-name (lispm-store-check--file file)
                                                                   lispm-store-check-root))
                                             used)))))
    (cons items (reverse lispm-store-check--problems))))

(defun lispm-store-check ()
  "Check the catalog, report, and exit Emacs: non-zero if there is a problem."
  (pcase-let ((`(,items . ,problems) (lispm-store-check-catalog)))
    (dolist (problem problems)
      (message "%s" problem))
    (if problems
        (message "\n%d problems." (length problems))
      (message "catalog.eld: %d items (%s), all well formed."
               (length items)
               (mapconcat (lambda (kind)
                            (let ((count (cl-count kind items :key (lambda (item) (plist-get (cdr item) :kind)))))
                              (format "%d %s%s" count kind (if (= count 1) "" "s"))))
                          '(app extension role skill) ", ")))
    (kill-emacs (if problems 1 0))))

(provide 'lispm-store-check)
;;; lispm-store-check.el ends here
