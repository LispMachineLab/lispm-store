;;; lispm-store-telegram-test.el --- Offline Telegram regressions -*- lexical-binding: t; -*-

;;; Commentary:
;; Run with emacs -Q --batch -l test/lispm-store-telegram-test.el \
;;   -f ert-run-tests-batch-and-exit
;; No Telega or LispM installation is needed.  Read the actual skill forms,
;; capture tool bodies and metadata without registering tools, and stub every
;; external operation.  This tests the skill contract, not TDLib compatibility.

;;; Code:
(require 'ert)
(require 'cl-lib)
(require 'seq)
(require 'subr-x)

(defvar lispm-store-telegram-test--tools nil)
(declare-function lispm-store-telegram-test--telegram_send nil (chat text &optional reply-to))

(let ((skill (expand-file-name
              "../skills/chat-telegram.org"
              (file-name-directory
               (or load-file-name (bound-and-true-p byte-compile-current-file) buffer-file-name)))))
  (with-temp-buffer
    (insert-file-contents skill)
    (goto-char (point-min))
    (re-search-forward "^#\\+begin_src emacs-lisp :lispm load$")
    (let* ((start (point))
           (end (progn (re-search-forward "^#\\+end_src$") (match-beginning 0))))
      (narrow-to-region start end)
      (goto-char (point-min))
      (while (progn (skip-chars-forward " \t\r\n") (not (eobp)))
        (let ((form (read (current-buffer))))
          (pcase (car form)
            ;; Never require Telega: even installed autoloads must not send.
            ('require nil)
            ('lispm-deftool
             (let ((name (nth 1 form))
                   (args (nth 2 form))
                   (body (nthcdr 4 form))
                   metadata)
               (while (keywordp (car body))
                 (setq metadata (plist-put metadata (pop body) (pop body))))
               (push (cons name metadata) lispm-store-telegram-test--tools)
               ;; Use a private test name, not the real tool/permission wrapper.
               (eval `(defun ,(intern (format "lispm-store-telegram-test--%s" name))
                          ,(let (names optional)
                             (dolist (arg args)
                               (when (and (plist-get (nthcdr 3 arg) :optional) (not optional))
                                 (push '&optional names)
                                 (setq optional t))
                               (push (car arg) names))
                             (nreverse names))
                        ,@body) t)))
            (_ (eval form t))))))))

(defmacro lispm-store-telegram-test--with-send (result &rest body)
  "Run BODY with RESULT as the single send response, capturing calls."
  (declare (indent 1) (debug t))
  `(let ((calls nil)
         (chat '(:id 42 :title "Offline")))
     (cl-letf (((symbol-function 'lispm-telegram-chat) (lambda (_) chat))
               ((symbol-function 'lispm-telegram--title) (lambda (_) "Offline"))
               ((symbol-function 'telega-fmt-text)
                (lambda (text) (list :@type "formattedText" :text text)))
               ((symbol-function 'telega--sendMessage)
                (lambda (&rest args) (push args calls) ,result)))
       ,@body)))

(ert-deftest lispm-store-telegram-send-nil-is-not-success ()
  (lispm-store-telegram-test--with-send nil
    (let ((failure (should-error (lispm-store-telegram-test--telegram_send "42" "hello"))))
      (should (string-match-p "not confirmed" (error-message-string failure))))
    (should (= 1 (length calls)))))

(ert-deftest lispm-store-telegram-send-rejects-invalid-acknowledgements ()
  (dolist (response '(t 42 "ok" (:ok t) (:@type "error" :code 400)
                      (:@type "message" :id 0 :chat_id 42)
                      (:@type "message" :id "1" :chat_id 42)
                      (:@type "message" :id 1 :chat_id 43)
                      (:@type "message" :chat_id 42)))
    (lispm-store-telegram-test--with-send response
      (should-error (lispm-store-telegram-test--telegram_send "42" "hello"))
      (should (= 1 (length calls))))))

(ert-deftest lispm-store-telegram-send-propagates-error-without-retry ()
  (lispm-store-telegram-test--with-send (error "TDLib rejected request")
    (should (equal '(error "TDLib rejected request")
                   (should-error (lispm-store-telegram-test--telegram_send "42" "hello"))))
    (should (= 1 (length calls)))))

(ert-deftest lispm-store-telegram-send-validates-state ()
  (dolist (state '((:@type "messageSendingStateFailed")
                   (:@type "unknown") t))
    (lispm-store-telegram-test--with-send
        (list :@type "message" :id 12 :chat_id 42 :sending_state state)
      (should-error (lispm-store-telegram-test--telegram_send "42" "hello"))
      (should (= 1 (length calls))))))

(ert-deftest lispm-store-telegram-send-pending-is-not-delivered ()
  (lispm-store-telegram-test--with-send
      '(:@type "message" :id -12 :chat_id 42
        :sending_state (:@type "messageSendingStatePending"))
    (let ((answer (lispm-store-telegram-test--telegram_send "42" "hello")))
      (should (string-prefix-p "Queued (delivery pending)" answer))
      (should-not (string-match-p "Sent" answer)))
    (should (= 1 (length calls)))))

(ert-deftest lispm-store-telegram-send-confirmed-and-reply-payload ()
  (lispm-store-telegram-test--with-send '(:@type "message" :id 12 :chat_id 42)
    (should (equal "Sent to Offline, replying to 9."
                   (lispm-store-telegram-test--telegram_send "42" "*plain*" 9)))
    (should (equal calls
                   (list (list chat
                               '(:@type "inputMessageText"
                                 :text (:@type "formattedText" :text "*plain*"))
                               '(:@type "inputMessageReplyToMessage" :message_id 9)
                               nil :sync-p t))))))

(ert-deftest lispm-store-telegram-send-no-reply-and-empty-input ()
  (lispm-store-telegram-test--with-send '(:@type "message" :id 12 :chat_id 42)
    (should (equal "Sent to Offline."
                   (lispm-store-telegram-test--telegram_send "42" "hello")))
    (should-not (nth 2 (car calls)))
    (setq calls nil)
    (dolist (text '("" " \n\t"))
      (should-error (lispm-store-telegram-test--telegram_send "42" text)))
    (should-not calls)))

(ert-deftest lispm-store-telegram-send-retains-approval-metadata ()
  (let ((metadata (alist-get 'telegram_send lispm-store-telegram-test--tools)))
    (should (eq 'chat (plist-get metadata :permission)))
    (should (eq t (plist-get metadata :always-ask)))
    (should (eq 'lambda (car (plist-get metadata :preview))))))

(provide 'lispm-store-telegram-test)
;;; lispm-store-telegram-test.el ends here
