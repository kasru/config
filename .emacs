;;
;; My .emacs
;;

(add-to-list 'load-path "/usr/share/emacs/site-lisp/emacs-goodies-el")

(add-to-list 'load-path "~/.emacs.d/")
(add-to-list 'load-path "~/.emacs.d/cedet-1.1/semantic")
(add-to-list 'load-path "~/.emacs.d/cedet-1.1/semantic/bovine")
(add-to-list 'load-path "~/.emacs.d/ecb-2.40.1")
(load-file "~/.emacs.d/cedet-1.1/common/cedet.el")

;; proxy
(setq url-proxy-services '(("no_proxy" . "tfs")
                           ("http" . "10.0.0.1:3128")))

;(codepage-setup "1251")
(set-language-environment "UTF-8")
;(prefer-coding-system 'utf-8)
;(setq default-process-coding-system '(utf-8-unix . utf-8-unix))

;(require 'pc-select)
;(require 'align)
;(require 'saveplace)
;(require 'env)
(require 'server)
(require 'compile)
;(require 'php-mode)

;;
;; Global options
;;
(fset 'yes-or-no-p 'y-or-n-p)
(setq default-tab-width 5)

;;
;; Screen settings
;;
(kill-buffer "*Messages*")

;; tabs
(require 'tabbar)
;(set-face-foreground 'tabbar-default "white")
;(set-face-background 'tabbar-default "RoyalBlue4")
(set-face-foreground 'tabbar-selected "white")
;(set-face-bold-p 'tabbar-selected t)
;(set-face-attribute 'tabbar-button nil :box '(:line-width 1 :color "gray72"))
(setq tabbar-buffer-groups-function
      (lambda ()
        (list
         (cond
          ((find (aref (buffer-name (current-buffer)) 0) " *") "*")
          (t "All Buffers"))
         )))
(tabbar-mode t)

;;ECB
(require 'ecb)
(global-set-key [C-f1] 'ecb-toggle-ecb)
(defun ecb-toggle-ecb()
  (interactive)
  (if ecb-minor-mode (ecb-deactivate) (ecb-activate)))

;;semantic
(require 'semantic)
(require 'semantic-load)
(require 'semanticdb)
(require 'semantic-gcc)
(require 'semantic-ia)
(require 'semantic-lex-spp)
(require 'ede)
(require 'eassist)

(setq semantic-load-turn-everything-on t)
(semantic-load-enable-excessive-code-helpers)
(global-ede-mode t)

(setq-mode-local c-mode semanticdb-find-default-throttle
                 '(project unloaded system recursive))
(setq-mode-local c++-mode semanticdb-find-default-throttle
                 '(project unloaded system recursive))


;; Global: CEDET uses GNU Global in order to help semantic in symref locations and tags definitions,
;; and to ede in project files locations (and it is used by auto-complete to).
;; CEDET doesn't handle the Global database, so we have to create and update it periodically with
;; the command gtags.

(when (cedet-gnu-global-version-check t)
  (require 'semanticdb-global)
;;  (add-to-list 'ede-locate-setup-options 'ede-locate-global)
  (semanticdb-enable-gnu-global-databases 'c-mode)
  (semanticdb-enable-gnu-global-databases 'c++-mode))


;; CScope: CEDET uses CScope in order to help semantic in symref locations and tags definitions,
;; and to ede in project files locations. CEDET handle automatically CScope databases,
;; so you don't need special commands for it.
(when (cedet-cscope-version-check t)
  (require 'semanticdb-cscope)
  (semanticdb-enable-cscope-databases)
;;  (add-to-list 'ede-locate-setup-options 'ede-locate-cscope)
)


;; IDutil: CEDET uses IDutils only for locating files in ede projects.
;; You have to create and update ID databases with the command mkid or with gtags -i.
(when (cedet-idutils-version-check t)
;;  (add-to-list 'ede-locate-setup-options 'ede-locate-idutils)
)

; CTags: CEDET uses CTags as replacement of internal ELisp parser, so it can speed up idle jobs.
; Semantic handles management of CTags databases.
(require 'semanticdb-ectag)
(when (semantic-ectag-version)
  (semantic-load-enable-primary-exuberent-ctags-support)
  (semantic-load-enable-secondary-exuberent-ctags-support))

;; Locate: CEDET uses it only for locating files in ede projects.
;; If you has installed locate it is used that cron update locate database once at day.
;(when (executable-find "locate")
;  (add-to-list 'ede-locate-setup-options 'ede-locate-locate))

;; And some variables set by customize in order to enable or disable some methods and fixing paths:
'(global-semantic-idle-completions-mode nil nil (semantic-idle))
'(global-semantic-idle-local-symbol-highlight-mode t nil (semantic-idle))
'(global-semantic-idle-summary-mode t nil (semantic-idle))
'(global-semantic-idle-tag-highlight-mode t nil (semantic-idle))
;'(global-semantic-stickyfunc-mode nil nil (semantic-util-modes)) ;Headline (remove tabbar)
(if (fboundp 'global-semantic-stickyfunc-mode)
    (global-semantic-stickyfunc-mode -1))
'(semantic-idle-scheduler-work-idle-time 15)
'(semanticdb-default-save-directory "~/.emacs.d/cache")
'(semanticdb-default-system-save-directory "~/.emacs.d/cache/system")

;;
;; Common routines
;;

(defun my-nonincremental-search-forward (string)
  "Read a string and search for it nonincrementally."
  (interactive "sSearch for string: ")
  (if (equal string "")
      (search-forward (car search-ring))
    (isearch-update-ring string nil)
    (search-forward string))
  (setq regexp-search-ring 'nil))

(defun my-nonincremental-re-search-forward (string)
  "Read a regular expression and search for it nonincrementally."
  (interactive "sSearch for regexp: ")
  (if (equal string "")
      (re-search-forward (car regexp-search-ring))
    (isearch-update-ring string t)
    (re-search-forward string))
  (setq search-ring 'nil))

(defun my-nonincremental-repeat-search-forward ()
  "Search forward for the previous search string."
  (interactive)
  (if (null search-ring)
      (if (null regexp-search-ring)
      (error "No previous search")))
  (if (null search-ring)
      (re-search-forward (car regexp-search-ring)))
  (if (null regexp-search-ring)
      (search-forward (car search-ring)))
)

(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))

(defun my-kill-buffer ()
  (interactive)
  (if server-buffer-clients
      (if (server-buffer-done (current-buffer)) (kill-buffer (current-buffer)))
    (kill-buffer (current-buffer))))

(defun my-kill-line ()
  (interactive)
  (beginning-of-line)
  (kill-line))

(defun relex-cvs-ediff ()
  (interactive)
  (let ((buf (current-buffer)))
    (vc-version-other-window (vc-workfile-version buffer-file-name))
    (ediff-buffers (buffer-name (current-buffer)) (buffer-name buf)))
)

;(defun comment-indent-cc-function ()
;    comment-column
;)

(defun get-cur-line-number ()
  (let ((opoint (point)) start)
    (save-excursion
      (save-restriction
	(goto-char (point-min))
	(widen)
	(forward-line 0)
	(setq start (point))
	(goto-char opoint)
	(forward-line 0)
        (1+ (count-lines 1 (point)))))))


(defun relex-date-comment ()
  (interactive)
  (let* ((reg_beg (if (c-region-is-active-p) (region-beginning) nil))
         (reg_end (if (null reg_beg) nil (region-end)))
         (l1 (if (null reg_beg) nil (save-excursion (goto-char reg_beg) (get-cur-line-number))))
         (l2 (if (null reg_end) nil (save-excursion (goto-char reg_end) (get-cur-line-number)))))
    (if (or (null l1) (= l1 l2))
        (save-excursion  (let* ((cc comment-column))
                           (setq comment-column 60)
                           (indent-for-comment)
                           (insert (format-time-string " %d.%m.%y " (current-time)))
                           (setq comment-column cc)))
      (relex-date-comment-region l1 l2)
      )
    )
  )

(defun relex-date-comment-region (l1 l2)
  (let* ((pos1 (save-excursion (goto-line l1) (end-of-line) (skip-chars-backward " \t") (current-column)))
         (pos2 (save-excursion (goto-line l2) (end-of-line) (skip-chars-backward " \t") (current-column)))
         (the-column (max 60 (max (+ 1 pos1) (+ 1 pos2)))))
    (save-excursion
      (goto-line l1)
      (end-of-line)
      (move-to-column pos1)
      (delete-region (point) (line-end-position))
      (indent-to (- the-column pos1) (- the-column pos1))
      (insert (concat comment-start (format-time-string " %d.%m.%y ... " (current-time)) comment-end))
      (goto-line l2)
      (move-to-column pos2)
      (delete-region (point) (line-end-position))
      (indent-to (- the-column pos2) (- the-column pos2))
      (insert (concat comment-start (format-time-string " ... %d.%m.%y " (current-time)) comment-end))
      )
    )
  )

(defun run-debugger ()
  (interactive)
  (if (string-equal mode-name "Perl")
     (perldb (buffer-name))
     (gdb (read-file-name "Executable to debug: "))))

(defun inspect-expr ()
  (interactive)
  (gud-print (gud-find-c-expr)))

(defun gen-password ()
  (interactive)
  (fresh-password-seed)
  (make-password mpw-qwerty-layout 10))

(defun my-c-newline-indent ()
  (interactive)
  (delete-trailing-whitespace)
  (newline)
  (c-indent-command))

(defun my-next-line-nomark (&optional arg)
;<down>
  (interactive "p")
  (delete-trailing-whitespace)
  (next-line-nomark arg)
  (setq this-command 'next-line))

(defun my-previous-line-nomark (&optional arg)
;<up>
  (interactive "p")
  (delete-trailing-whitespace)
  (previous-line-nomark arg)
  (setq this-command 'previous-line))

(defun my-scroll-down-nomark (&optional arg)
;<prior>         scroll-down-nomark
  (interactive "P")
  (delete-trailing-whitespace)
  (scroll-down-nomark arg))

(defun my-scroll-up-nomark (&optional arg)
;<next>          scroll-up-nomark
  (interactive "P")
  (delete-trailing-whitespace)
  (scroll-up-nomark arg))

(defun my-scroll-down1 (&optional arg)
;<prior>         scroll-down-nomark
  (interactive "P")
  (if (null arg) (setq arg 1))
  (delete-trailing-whitespace)
  (scroll-down arg))

(defun my-scroll-up1 (&optional arg)
;<next>          scroll-up-nomark
  (interactive "P")
  (if (null arg) (setq arg 1))
  (delete-trailing-whitespace)
  (scroll-up arg))


(setq evm-coding-systems-list (make-ring 5))
(ring-insert evm-coding-systems-list 'utf-8-unix)
(ring-insert evm-coding-systems-list 'cp1251-dos)
(ring-insert evm-coding-systems-list 'alternativnyj-dos)
(ring-insert evm-coding-systems-list 'koi8-r-unix)
(ring-insert evm-coding-systems-list 'iso-8859-5-unix)

(defun my-change-buffer-coding ()
  (interactive)
  (let* ((keys (recent-keys))
         (len (length keys))
         (key1 (if (> len 0) (elt keys (- len 1)) nil))
         (key2 (if (> len 1) (elt keys (- len 2)) nil))
         cs)
    (if (eq key1 key2)
        (setcar evm-coding-systems-list
                (ring-plus1 (car evm-coding-systems-list)
                            (ring-length evm-coding-systems-list)))
      (setcar evm-coding-systems-list 0))
    (set-buffer-multibyte t)
    (set-buffer-file-coding-system (aref (cddr evm-coding-systems-list)
                                         (car evm-coding-systems-list)))
    ;(set-buffer-modified-p nil)
    ))

(defun my-clipboard-yank ()
  (interactive)
  (progn (if (c-region-is-active-p) (delete-active-region nil))
         (clipboard-yank))
;  (if (eq window-system 'w32)
;      (progn (if (c-region-is-active-p) (delete-active-region nil))
;             (clipboard-yank))
;    (let (text)
;      (if (and (x-selection-exists-p 'PRIMARY)
;               (null (x-selection-owner-p 'PRIMARY)))
;          (setq text (x-get-selection 'PRIMARY 'UTF8_STRING)))
;      (if (string= text "")
;          (setq text nil))
;      (if (and (null text) (x-selection-exists-p 'CLIPBOARD))
;          (setq text (x-get-selection 'CLIPBOARD 'UTF8_STRING)))
;      (if (string= text "")
;          (setq text nil))
;      (if (not (null text))
;          (progn (if (c-region-is-active-p) (delete-active-region nil))
;                 (insert text)))
;      )
;    )
  )

(defun my-clipboard-kill-ring-save ()
  (interactive)
  (x-set-selection 'CLIPBOARD (filter-buffer-substring (region-beginning) (region-end)))
  (clipboard-kill-ring-save (region-beginning) (region-end))
)
;;
;; doxygen
;(setq doxymacs-function-comment-template
; '((let ((next-func (doxymacs-find-next-func)))
;     (if next-func
;     (list
;      'l
;      "/** " '> 'n
;      " * " '>
;(doxymacs-doxygen-command-char) "method " '>
;(regexp-quote (cdr (assoc 'func next-func)))
;      'p '> 'n
;      " * " '> 'n
;      (doxymacs-parm-tempo-element (cdr (assoc 'args next-func)))
;      (unless (string-match
;                   (regexp-quote (cdr (assoc 'return next-func)))
;                   doxymacs-void-types)
;        '(l " * " > n " * " (doxymacs-doxygen-command-char)
;        "return " (p "Returns: ") > n))
;      " */" '>)
;       (progn
;     (error "Can't find next function declaration.")
;     nil)))))

;;
;; CC mode settings
(c-add-style  "kas"  (quote (
                             (c-basic-offset . 5)
                             (indent-tabs-mode . nil)
                             (c-comment-only-line-offset . 0)
                             (whitespace-auto-cleanup . t)
                             (whitespace-silent . t)
                             (whitespace-check-buffer-trailing . t)
                             (whitespace-check-buffer-ateol . t)
                             (whitespace-check-buffer-indent . nil)
                             (whitespace-check-buffer-spacetab . t)
                             (show-trailing-whitespace . t)
                             (c-offsets-alist
                              (namespace-open . 0)
                              (innamespace . 0)
                              (namespace-close . 0)
                              (inextern-lang . 0)
                  (inclass . +)
                  (defun-open . 0)
                  (defun-close . 0)
                  (defun-block-intro . +)
                              (statement-block-intro . +)
                  (substatement-open . 0)
                  (case-label . +)
                  (label . 0)
                  (statement-cont . +)))) )

(defun my-cc-mode-common-hook ()
  ;(setq comment-indent-function 'comment-indent-cc-function)
  (local-set-key [return] 'my-c-newline-indent)
  (local-set-key [(shift insert)] 'my-clipboard-yank)
  (local-set-key [(control insert)] 'my-clipboard-kill-ring-save)
  (local-set-key [(shift delete)] 'clipboard-kill-region)
  (local-set-key [up] 'my-previous-line-nomark)
  (local-set-key [down] 'my-next-line-nomark)
  (local-set-key [prior] 'my-scroll-down-nomark)
  (local-set-key [next] 'my-scroll-up-nomark)

  (local-set-key [(control return)] 'semantic-ia-complete-symbol)
  (local-set-key "\C-c?" 'semantic-ia-complete-symbol-menu)
  (local-set-key "\C-c>" 'semantic-complete-analyze-inline)
  (local-set-key "\C-cp" 'semantic-analyze-proto-impl-toggle)
  ;(local-set-key "." 'semantic-complete-self-insert)
  ;(local-set-key ">" 'semantic-complete-self-insert)

  (local-set-key [(control <)] 'semantic-goto-definition)
  (local-set-key [(control >)] 'semantic-pop-tag-mark)

  (define-key c-mode-base-map (kbd "M-o") 'eassist-switch-h-cpp)
  (define-key c-mode-base-map (kbd "M-m") 'eassist-list-methods)

  (flyspell-prog-mode)

  (setq comment-start "/*")
  (setq comment-end "*/")
)

(defun my-message-mode-hook ()
  ;(flyspell-mode 1)
)

(defun my-text-mode-hook ()
  ;(flyspell-mode 0)
  ;(flyspell-buffer)
)


(add-hook 'message-mode-hook 'my-message-mode-hook)
(add-hook 'c-mode-common-hook 'my-cc-mode-common-hook)
(add-hook 'c++-mode-common-hook 'my-cc-mode-common-hook)
(add-hook 'text-mode-hook 'my-text-mode-hook)

;=======================================
;server
(if (not (eq window-system 'w32))
    (progn

      (require 'server)

      (defun my-server-switch-hook ()
        (raise-frame (selected-frame))
        (other-frame 0))

      (if (not (file-exists-p (concat "/tmp/emacs" (number-to-string (user-real-uid)) "/server" ) ))
          (server-start))

      (add-hook 'server-visit-hook  'my-server-switch-hook)
      (add-hook 'server-visit-hook 'save-place-find-file-hook t)
      (add-hook 'server-switch-hook 'my-server-switch-hook)
      (add-hook 'server-switch-hook 'save-place-find-file-hook t)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;tag-mode
(require 'etags)
(defun my-tags-apropos (tagname)
  (interactive (find-tag-interactive "Apropos tag: "))
  (tags-apropos tagname)
  (switch-to-buffer-other-window "*Tags List*")
  (tag-mode)
)
(global-set-key [(meta >)]      'my-tags-apropos)
(global-set-key [(alt >)]       'my-tags-apropos)
;(global-set-key [(meta \])]        'pop-tag-mark)

(defun get-cur-line()
  (save-excursion
    (interactive)
    (let* ((oldpoint (point)) (start (point)) (end (point)))
      (beginning-of-line 1)
      (setq start (point))
      (end-of-line 1)
      (setq end (point))
      (setq sss (buffer-substring-no-properties start end))
      )))
(defvar tag-mode-map (make-sparse-keymap)
  "Keymap for tag mode.")
(define-key tag-mode-map [return] '(lambda () (interactive) (find-tag (get-cur-line))))

(defun tag-mode ()
  "Major mode for viewing help text and navigating references in it.
Entry to this mode runs the normal hook `tag-mode-hook'.
Commands:
\\{tag-mode-map}"
  (interactive)
  (setq mode-name "Tag")
  (setq major-mode 'tag-mode)
  (use-local-map tag-mode-map)
  (toggle-read-only 1)
  (run-hooks 'tag-mode-hook))
;;;;;end tag mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;semantic
(defvar semantic-tags-location-ring (make-ring 20))

(defun semantic-goto-definition (point)
  "Goto definition using semantic-ia-fast-jump save the pointer marker if tag is found"
  (interactive "d")
  (condition-case err
      (progn
        (ring-insert semantic-tags-location-ring (point-marker))
        (semantic-ia-fast-jump point))
    (error
     ;;if not found remove the tag saved in the ring
     (set-marker (ring-remove semantic-tags-location-ring 0) nil nil)
     (signal (car err) (cdr err)))))

(defun semantic-pop-tag-mark ()
  "popup the tag save by semantic-goto-definition"
  (interactive)
  (if (ring-empty-p semantic-tags-location-ring)
      (message "%s" "No more tags available")
    (let* ((marker (ring-remove semantic-tags-location-ring 0))
              (buff (marker-buffer marker))
                 (pos (marker-position marker)))
      (if (not buff)
            (message "Buffer has been deleted")
        (switch-to-buffer buff)
        (goto-char pos))
      (set-marker marker nil nil))))

;(defun fjump-toggle-fjump()
;  (interactive)
;  (if ecb-minor-mode (ecb-deactivate) (ecb-activate)))
;;;;;end semantic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-skipbuf ( xbf)
  (or
      (null (buffer-file-name xbf))
      (string-match "TAGS" (buffer-name xbf)))
)

(defun my-buffer-list ()
  (let* ((bl (buffer-list)) (out (buffer-list)) )
    (while bl
      (if  (my-skipbuf (car bl)) (setq out (delete (car bl) out)))
      (setq bl (cdr bl)))
    (progn  out)))

(defun my-compile (command)
  (interactive
   (if (or compilation-read-command current-prefix-arg)
       (list (read-from-minibuffer "Compile command: "
                   (eval compile-command) nil nil
                   '(compile-history . 1)))
     (list (eval compile-command))))
  (unless (equal command (eval compile-command))
    (setq compile-command command))
  (switch-to-buffer-other-window "*compilation*")
  (compile command))

(defun my-switch-buffer ()
  (interactive)
  (let* ( (bl (my-buffer-list)) )
    (if (not (my-skipbuf (current-buffer))) (setq bl (cdr bl)))
    (if (car bl)
    (switch-to-buffer (progn (while (cdr bl)
                   (setq bl (cdr bl))) (car bl))))))


;;(codepage-setup "1251")
(define-coding-system-alias 'windows-1251 'cp1251)
(setq-default coding-system-for-read 'cp1251)
(set-selection-coding-system 'cp1251)
(setq default-input-method 'russian-computer)

;(setq w3m-coding-system 'cp1251
;      w3m-default-coding-system 'cp1251
;      w3m-file-coding-system 'cp1251
;      w3m-file-name-coding-system 'cp1251
;      w3m-bookmark-file-coding-system 'cp1251
;      w3m-input-coding-system 'cp1251
;      w3m-output-coding-system 'cp1251
;      w3m-terminal-coding-system 'cp1251
;      w3m-google-feeling-lucky-charset 'cp1251)

;========================================
;Face
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ediff-even-diff-face-A ((((class color) (background dark)) (:background "grey25"))))
 '(ediff-even-diff-face-B ((((class color) (background dark)) (:background "grey25"))))
 '(ediff-odd-diff-face-A ((((class color) (background dark)) (:background "grey25"))))
 '(ediff-odd-diff-face-B ((((class color) (background dark)) (:background "grey25"))))
 '(font-lock-builtin-face ((t (:foreground "#BF00BF"))))
 '(font-lock-comment-face ((t (:foreground "#009898"))))
 '(font-lock-constant-face ((t (:foreground "red1"))))
 '(font-lock-function-name-face ((t (:foreground "#00d0a0"))))
 '(font-lock-keyword-face ((t (:foreground "#f07200"))))
 '(font-lock-string-face ((t (:foreground "#d99800"))))
 '(font-lock-type-face ((t (:foreground "#00a000"))))
 '(font-lock-variable-name-face ((t (:foreground "gold2"))))
 '(fringe ((((class color) (background dark)) (:background "grey15"))))
 '(header-line ((default (:background "grey20" :underline "grey50")) (((class color grayscale) (background dark)) nil)))
 '(highlight ((t (:foreground "black" :background "light yellow"))))
 '(mode-line ((t (:foreground "#d0d0d0" :background "dark cyan"))))
 '(region ((t (:background "dark blue"))))
 '(show-paren-match ((((class color) (background dark)) (:foreground "turquoise"))))
 '(tool-bar ((((type x w32 mac) (class color)) (:background "#004f00" :foreground "#d0d0d0" :box (:line-width 1 :style released-button)))))
)

;========================================
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(adaptive-fill-mode t)
 '(align-c++-modes (quote (jde-mode c++-mode c-mode java-mode)))
 '(align-indent-before-aligning t)
 '(backup-inhibited t t)
 '(blink-cursor-mode nil)
 '(c-default-style (quote ((c-mode . "kas") (cc-mode . "kas") (c++-mode . "kas") (java-mode . "kas") (other . "gnu"))))
 '(c-macro-preprocessor "g++ -E ")
 '(column-number-mode t)
 '(compilation-window-height 8)
 '(compile-command "LANG=C make")
 '(default-frame-alist (quote ((turn-on-font-lock-if-enabled) (vertical-scroll-bars) (tool-bar-lines . 0) (menu-bar-lines . 0) (cursor-color . "HotPink") (cursor-type . box) (width . 100) (height . 42) (foreground-color . "#BFBFA7") (background-color . "#000000"))))
 '(default-major-mode (quote text-mode) t)
 '(display-column-mode t)
 '(doxymacs-doxygen-style "JavaDoc")
 '(ecb-layout-name "left1")
; '(ecb-layout-name "leftright1")
 '(ecb-options-version "2.32")
 '(ecb-prescan-directories-for-emptyness nil)
 '(ecb-primary-secondary-mouse-buttons (quote mouse-1--C-mouse-1))
 '(ecb-source-path (quote ("/home/kas/work")))
 '(ecb-tip-of-the-day nil)
 '(ede-project-directories (quote ("/home/kas")))
 '(ediff-window-setup-function (quote ediff-setup-windows-plain))
 '(font-lock-maximum-decoration t)
 '(frame-background-mode (quote dark))
 '(global-font-lock-mode (quote t) nil (font-lock))
 '(gnus-article-display-hook (quote (gnus-article-hide-headers-if-wanted gnus-article-hide-boring-headers gnus-article-treat-overstrike gnus-article-highlight gnus-article-emphasize)))
 '(gnus-group-charset-alist (quote (("^hk\\>\\|^tw\\>\\|\\<big5\\>" cn-big5) ("^cn\\>\\|\\<chinese\\>" cn-gb-2312) ("^fj\\>\\|^japan\\>" iso-2022-jp-2) ("^tnn\\>\\|^pin\\>\\|^sci.lang.japan" iso-2022-7bit) ("^relcom\\>" koi8-r) ("^fido7\\>" koi8-r) ("^\\(cz\\|hun\\|pl\\|sk\\|hr\\)\\>" iso-8859-2) ("^israel\\>" iso-8859-1) ("^han\\>" euc-kr) ("^alt.chinese.text.big5\\>" chinese-big5) ("^soc.culture.vietnamese\\>" vietnamese-viqr) ("^\\(comp\\|rec\\|alt\\|sci\\|soc\\|news\\|gnu\\|bofh\\)\\>" iso-8859-1) (".*" koi8-r))))
 '(gnus-newsgroup-ignored-charsets (quote (unknown-8bit x-unknown iso-8859-1)))
 '(gnus-summary-line-format "%U%R%z%I%(%[%4L: %-20,20n%]%) %s" )
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(ispell-local-dictionary "english")
 '(jit-lock-contextually (quote t))
 '(jit-lock-mode (quote t) t)
 '(jit-lock-stealth-time 0.25)
 '(kill-whole-line t)
 '(line-number-mode t)
 '(message-log-max nil)
 '(message-send-mail-function (quote smtpmail-send-it))
 '(options-save-faces t)
 '(pc-selection-mode t nil (pc-select))
 '(query-user-mail-address nil)
 '(remote-shell-program "/usr/bin/ssh")
 '(save-place t nil (saveplace))
 '(show-paren-mode t nil (paren))
 '(smtpmail-smtp-server "mail")
 '(transient-mark-mode t)
 '(truncate-lines t)
 '(x-select-enable-clipboard t))

;========================================
(defun my-grep-compute-defaults ()
  (setq grep-command
    (if (equal (condition-case nil  ; in case "grep" isn't in exec-path
               (call-process grep-program nil nil nil
                     "-e" "foo" null-device)
             (error nil))
           1)
        (format "%s -n -e " grep-program)
      (format "%s -n " grep-program)))
  (unless grep-find-use-xargs
    (setq grep-find-use-xargs
      (if (and
               (equal (call-process "find" nil nil nil
                                    null-device "-print0")
                      0)
               (equal (call-process "xargs" nil nil nil
                                    "-0" "-e" "echo")
             0))
          'gnu)))
  (setq grep-find-command
    (cond ((eq grep-find-use-xargs 'gnu)
           (format "find . -type f -name '*.[chly]' -print0 | xargs -0 -e %s"
               grep-command))
          (grep-find-use-xargs
           (format "find . -type f -name '*.[chly]' -print | xargs %s" grep-command))
          (t (cons (format "find . -type f -name '*.[chly]' -exec %s {} /dev/null \\;"
                   grep-command)
               (+ 38 (length grep-command)))))))
(my-grep-compute-defaults)

(if (eq window-system 'w32)
    (set-default-font "-outline-Consolas-normal-r-normal-normal-18-*-96-96-c-*-iso10646-1")
    ;(set-default-font "-outline-Courier New-normal-r-normal-normal-19-*-96-96-c-*-iso10646-1")
  (set-default-font "-misc-fixed-medium-r-normal--20-200-75-75-c-100-iso10646-1")
  ;(set-default-font "-monotype-andale mono-medium-r-normal--16-0-120-120-c-0-iso10646-1")
)

(setq load-path (cons "~/share/emacs/site-lisp" load-path))
;(require 'doxymacs)

;(set-default-font "-misc-fixed-medium-r-normal--20-200-75-75-c-100-iso10646-1")
;(set-default-font "-cronyx-fixed-bold-r-normal--16-120-100-100-c-80-koi8-r")
;(set-default-font "-misc-fixed-bold-r-normal--18-120-100-100-c-90-iso10646-1")
;(read-abbrev-file "~/.emacs_abbrevs")
;(setq load-path (cons "/usr/emacs21/share/emacs/21.0.105/lisp/w3-4.0pre.46/lisp" load-path))
;(require 'w3-auto)
;dictionary
;(load-library "dict")
;(global-set-key [(meta insert)] 'find-translate)


(setq auto-mode-alist
  (mapc
   (lambda (elt)
     (cons (purecopy (car elt)) (cdr elt)))
   '(("\\.te?xt\\'" . text-mode)
     ("\\.c\\'" . c++-mode)
;     ("\\.php\\'" . php-mode)
     ("\\.h\\'" . c++-mode)
     ("\\.tex\\'" . tex-mode)
     ("\\.ltx\\'" . latex-mode)
     ("\\.el\\'" . emacs-lisp-mode)
     ("\\.scm\\'" . scheme-mode)
     ("\\.l\\'" . lisp-mode)
     ("\\.lisp\\'" . lisp-mode)
     ("\\.f\\'" . fortran-mode)
     ("\\.F\\'" . fortran-mode)
     ("\\.for\\'" . fortran-mode)
     ("\\.p\\'" . pascal-mode)
     ("\\.pas\\'" . pascal-mode)
     ("\\.ad[abs]\\'" . ada-mode)
     ("\\.\\([pP]\\([Llm]\\|erl\\)\\|al\\)\\'" . perl-mode)
     ("\\.s?html?\\'" . html-mode)
     ("\\.inl\\'" . c++-mode)
     ("\\.cc\\'" . c++-mode)
     ("\\.hh\\'" . c++-mode)
     ("\\.hpp\\'" . c++-mode)
     ("\\.C\\'" . c++-mode)
     ("\\.H\\'" . c++-mode)
     ("\\.cpp\\'" . c++-mode)
     ("\\.cxx\\'" . c++-mode)
     ("\\.hxx\\'" . c++-mode)
     ("\\.c\\+\\+\\'" . c++-mode)
     ("\\.h\\+\\+\\'" . c++-mode)
     ("\\.m\\'" . objc-mode)
     ("\\.java\\'" . java-mode)
     ("\\.mk\\'" . makefile-mode)
     ("\\Definition\\'" . makefile-mode)
     ("\\(M\\|m\\|GNUm\\)akefile\\(\\.in\\)?\\'" . makefile-mode)
     ("\\.am\\'" . makefile-mode)   ;For Automake.
     ;; Less common extensions come here
     ;; so more common ones above are found faster.
     ("\\.texinfo\\'" . texinfo-mode)
     ("\\.te?xi\\'" . texinfo-mode)
     ("\\.s\\'" . asm-mode)
     ("\\.S\\'" . asm-mode)
     ("\\.asm\\'" . asm-mode)
     ("ChangeLog\\'" . change-log-mode)
     ("change\\.log\\'" . change-log-mode)
     ("changelo\\'" . change-log-mode)
     ("ChangeLog\\.[0-9]+\\'" . change-log-mode)
     ;; for MSDOS and MS-Windows (which are case-insensitive)
     ("changelog\\'" . change-log-mode)
     ("changelog\\.[0-9]+\\'" . change-log-mode)
     ("\\$CHANGE_LOG\\$\\.TXT" . change-log-mode)
     ("\\.scm\\.[0-9]*\\'" . scheme-mode)
     ("\\.[ck]?sh\\'\\|\\.shar\\'\\|/\\.z?profile\\'" . sh-mode)
     ("\\(/\\|\\`\\)\\.\\(bash_profile\\|z?login\\|bash_login\\|z?logout\\)\\'" . sh-mode)
     ("\\(/\\|\\`\\)\\.\\(bash_logout\\|shrc\\|[kz]shrc\\|bashrc\\|t?cshrc\\|esrc\\)\\'" . sh-mode)
     ("\\(/\\|\\`\\)\\.\\([kz]shenv\\|xinitrc\\|startxrc\\|xsession\\)\\'" . sh-mode)
     ("\\.m?spec\\'" . sh-mode)
     ("\\.mm\\'" . nroff-mode)
     ("\\.me\\'" . nroff-mode)
     ("\\.ms\\'" . nroff-mode)
     ("\\.man\\'" . nroff-mode)
     ("\\.\\(u?lpc\\|pike\\|pmod\\)\\'" . pike-mode)
     ("\\.TeX\\'" . tex-mode)
     ("\\.sty\\'" . latex-mode)
     ("\\.cls\\'" . latex-mode)     ;LaTeX 2e class
     ("\\.clo\\'" . latex-mode)     ;LaTeX 2e class option
     ("\\.bbl\\'" . latex-mode)
     ("\\.bib\\'" . bibtex-mode)
     ("\\.sql\\'" . sql-mode)
     ("\\.m4\\'" . m4-mode)
     ("\\.mc\\'" . m4-mode)
     ("\\.mf\\'" . metafont-mode)
     ("\\.mp\\'" . metapost-mode)
     ("\\.vhdl?\\'" . vhdl-mode)
     ("\\.article\\'" . text-mode)
     ("\\.letter\\'" . text-mode)
     ("\\.tcl\\'" . tcl-mode)
     ("\\.exp\\'" . tcl-mode)
     ("\\.itcl\\'" . tcl-mode)
     ("\\.itk\\'" . tcl-mode)
     ("\\.icn\\'" . icon-mode)
     ("\\.sim\\'" . simula-mode)
     ("\\.mss\\'" . scribe-mode)
     ("\\.f90\\'" . f90-mode)
     ("\\.indent\\.pro\\'" . fundamental-mode) ; to avoid idlwave-mode
     ("\\.pro\\'" . idlwave-mode)
     ("\\.lsp\\'" . lisp-mode)
     ("\\.awk\\'" . awk-mode)
     ("\\.prolog\\'" . prolog-mode)
     ("\\.tar\\'" . tar-mode)
     ("\\.\\(arc\\|zip\\|lzh\\|zoo\\|jar\\)\\'" . archive-mode)
     ("\\.\\(ARC\\|ZIP\\|LZH\\|ZOO\\|JAR\\)\\'" . archive-mode)
     ;; Mailer puts message to be edited in
     ;; /tmp/Re.... or Message
     ("\\`/tmp/Re" . text-mode)
     ("/Message[0-9]*\\'" . text-mode)
     ("/drafts/[0-9]+\\'" . mh-letter-mode)
     ("\\.zone\\'" . zone-mode)
     ;; some news reader is reported to use this
     ("\\`/tmp/fol/" . text-mode)
     ("\\.y\\'" . c-mode)
     ("\\.ypp\\'" . c++-mode)
     ("\\.lex\\'" . c-mode)
     ("\\.lpp\\'" . c++-mode)
     ("\\.oak\\'" . scheme-mode)
     ("\\.sgml?\\'" . sgml-mode)
     ("\\.xml\\'" . sgml-mode)
     ("\\.dtd\\'" . sgml-mode)
     ("\\.ds\\(ss\\)?l\\'" . dsssl-mode)
     ("\\.idl\\'" . idl-mode)
     ;; .emacs following a directory delimiter
     ;; in Unix, MSDOG or VMS syntax.
     ("[]>:/\\]\\..*emacs\\'" . emacs-lisp-mode)
     ("\\`\\..*emacs\\'" . emacs-lisp-mode)
     ;; _emacs following a directory delimiter
     ;; in MsDos syntax
     ("[:/]_emacs\\'" . emacs-lisp-mode)
     ("/crontab\\.X*[0-9]+\\'" . shell-script-mode)
     ("\\.ml\\'" . lisp-mode)
     ("\\.\\(asn\\|mib\\|smi\\)\\'" . snmp-mode)
     ("\\.\\(as\\|mi\\|sm\\)2\\'" . snmpv2-mode)
     ("\\.\\(diffs?\\|patch\\|rej\\)\\'" . diff-mode)
     ("\\.\\(dif\\|pat\\)\\'" . diff-mode) ; for MSDOG
     ("\\.[eE]?[pP][sS]\\'" . ps-mode)
     ("configure\\.\\(ac\\|in\\)\\'" . autoconf-mode)
     ("BROWSE\\'" . ebrowse-tree-mode)
     ("\\.ebrowse\\'" . ebrowse-tree-mode)
     ("#\\*mail\\*" . mail-mode)
     ;; Get rid of any trailing .n.m and try again.
     ;; This is for files saved by cvs-merge that look like .#<file>.<rev>
     ;; or .#<file>.<rev>-<rev> or VC's <file>.~<rev>~.
     ;; Using mode nil rather than `ignore' would let the search continue
     ;; through this list (with the shortened name) rather than start over.
     ("\\.~?[0-9]+\\.[0-9][-.0-9]*~?\\'" ignore t)
     ;; The following should come after the ChangeLog pattern
     ;; for the sake of ChangeLog.1, etc.
     ;; and after the .scm.[0-9] and CVS' <file>.<rev> patterns too.
     ("\\.[1-9]\\'" . nroff-mode)
     ("\\.g\\'" . antlr-mode))))

(set-background-color "#10100E")
(set-foreground-color "#B3B39A")
(set-cursor-color     "HotPink")

;; wheel mouse
(global-set-key [mouse-4] 'my-scroll-down1)
(global-set-key [mouse-5] 'my-scroll-up1)
;(global-set-key [mouse-4] 'my-previous-line-nomark)
;(global-set-key [mouse-5] 'my-next-line-nomark)


(put 'erase-buffer 'disabled nil)

;;
;; Key bindings
;;
(global-set-key [(alt f4)]      'kill-emacs)
(global-set-key [(meta f4)]      'kill-emacs)
(global-set-key [help]      'info)
(global-set-key [(alt x)]       'execute-extended-command)
(global-set-key [home]      'beginning-of-line)
(global-set-key [end]       'end-of-line)

(global-set-key [(control home)]'beginning-of-buffer)
(global-set-key [(control end)] 'end-of-buffer)

(global-set-key [f1]        'manual-entry)

(global-set-key [(control b)] 'bookmark-set)
(global-set-key [(control j)] 'bookmark-jump)

(global-set-key [f2]        'save-buffer)
(global-set-key [(shift f2)]    'write-file)
(global-set-key [f3]        'my-nonincremental-repeat-search-forward)
(global-set-key [(control o)]   'find-file)
(global-set-key [(control f4)]  'my-kill-buffer)
(global-set-key [f4]        'next-error)
(global-set-key [(shift f4)]    'previous-error)
(global-set-key [f5]        'delete-other-windows)
(global-set-key [f6]        'other-window)
(global-set-key [(control f6)]  'bury-buffer)

;(toggle-case-fold-search)
(global-set-key [f7]        'my-nonincremental-search-forward)
(global-set-key [(control f)]   'my-nonincremental-search-forward)
(global-set-key [(shift f7)]    'my-nonincremental-repeat-search-forward)
;(global-set-key [(control i)]   'isearch-forward)
;(global-set-key [(control s)]   'save-buffer)
(global-set-key [(control  f7)] 'query-replace)
(define-key ctl-x-map [f7] 'my-nonincremental-re-search-forward)
(define-key ctl-x-map [(control  f7)] 'query-replace-regexp)

(global-set-key [(meta f7)] 'grep-find)
(global-set-key [(alt f7)]  'grep-find)
(global-set-key [(meta f8)]     'goto-line)
(global-set-key [(alt f8)]     'goto-line)
(global-set-key [(control g)]   'goto-line)
(global-set-key [f9]            'gud-break)
(global-set-key [(control f9)]  'my-compile)
(global-set-key [f10]       'gud-next)
(global-set-key [f11]       'gud-step)
(global-set-key [(shift f10)]   'gud-cont)
(global-set-key [(shift f11)]   'gud-finish)
;(global-set-key "M-,"  'tags-search)
(global-set-key [f12]       'inspect-expr)
;(global-set-key [(control f12)] 'kill-emacs)

(global-set-key [(shift insert)] 'my-clipboard-yank)
(global-set-key [(control insert)] 'my-clipboard-kill-ring-save)
(global-set-key [(shift delete)] 'clipboard-kill-region)

(global-set-key [(meta backspace)]    'undo)
(global-set-key [(alt backspace)]    'undo)
(global-set-key [(control backspace)] 'backward-kill-word)
(global-set-key [(control delete)]    'kill-word)
;(global-set-key [(control tab)]       'bury-buffer)
;(global-set-key [(control tab)]       'my-switch-buffer)
(global-set-key [(control tab)] 'tabbar-forward)        ;; - переключение вперед
(global-set-key [(control shift tab)] 'tabbar-backward) ;; а теперь разворачиваемся на 180 градусов - и снова вперед

(global-set-key [(meta  up)]    'my-scroll-down1)
(global-set-key [(alt   up)]    'my-scroll-down1)
(global-set-key [(meta  down)]  'my-scroll-up1)
(global-set-key [(alt   down)]  'my-scroll-up1)

(global-set-key [(control \`)] 'buffer-menu)
(global-set-key [(control y)]   'my-kill-line)

(global-set-key [(control z)]   'undo)
(global-set-key [(control \\)]  'relex-date-comment)
(global-set-key [(meta  d)] 'relex-cvs-ediff)
(global-set-key [(alt   d)] 'relex-cvs-ediff)
(global-set-key [(control \])]    'match-paren)
(global-set-key [(meta  p)]     'bookmark-set)
(global-set-key [(alt   p)]     'bookmark-set)
(global-set-key [(meta shift p)] 'bookmark-jump)
(global-set-key [(alt shift p)] 'bookmark-jump)
(global-set-key [(control f8)] 'my-change-buffer-coding)
(global-set-key [(control n)] 'global-linum-mode)

;(set-fill-column 1000) ; it's to dissable auto-line wrapping

;(require 'psvn)
;(tool-bar-mode -1)
;(menu-bar-mode -1)

(require 'color-theme)   ;;подгружаем "модуль раскраски"
(color-theme-initialize) ;;подгрузить библиотеку цветовых схем
(color-theme-arjen)      ;;выбрать конкретную схему
