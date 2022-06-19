(setq gc-cons-threshold 10000000)

(defmacro after (modules &rest body)
  (declare (indent 1))
  (cond
   ((vectorp modules)
    (let ((prog (macroexp-progn body)))
      (seq-reduce (lambda (a b) `(with-eval-after-load ,b ,a))
                  modules
                  prog)))
   (t `(with-eval-after-load ,modules ,@body))))

(global-set-key [f1] #'previous-buffer)
(global-set-key [f2] #'next-buffer)
(global-set-key [f3] (lambda () (interactive) (point-to-register ?z)))
(global-set-key [f4] (lambda () (interactive) (jump-to-register ?z)))
(global-set-key [f5] #'recompile)

(setq default-directory "~")
(setq visible-bell t)
(setq ring-bell-function (lambda ()
                           (invert-face 'mode-line)
                           (run-with-timer 0.05 nil #'invert-face 'mode-line)))
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))	;; cancer cured 2
(setq inhibit-startup-message t)				;; remove start message
(scroll-bar-mode -1)						;; remove scroll bar
(tool-bar-mode -1)						;; remove tool bar
(menu-bar-mode -1)						;; remove menu
(tooltip-mode -1)						;; remove tooltip
(set-fringe-mode '(15 . 0))					;; define fringes
(defalias 'yes-or-no-p 'y-or-n-p)				;; cancer cured
(hl-line-mode) 

(set-face-attribute 'default nil :font "Victor Mono" :height 140 :weight 'medium)

(custom-theme-set-faces
 'user
 '(variable-pitch ((t (:family "ETBembo" :height 140))))
 '(fixed-pitch ((t ( :family "Victor Mono" :height 140)))))

;; line numbers
(column-number-mode)
(global-display-line-numbers-mode t)


(setq redisplay-dont-pause t
      scroll-margin 1
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)

(defvar p-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'multiple-cursors)
(require 'multiple-cursors)

(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

(straight-use-package 'gcmh)
(gcmh-mode 1)

(straight-use-package 'amx)
(require 'amx)
(amx-mode)

(straight-use-package 'ido-yes-or-no)
(require 'ido-yes-or-no)
(ido-yes-or-no-mode 1)

(straight-use-package 'ido-completing-read+)
(require 'ido-completing-read+)
(ido-ubiquitous-mode 1)

(require 'icomplete)
(icomplete-mode 1)

(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(setq ido-decorations '(" | " "" " ⊗ " " ⊗ ..." "" "" " ∄" " ∃" " [Not readable]" " [Too big]" " [Confirm]"))
(setq ido-use-faces t)
(setq ido-use-virtual-buffers t)
(setq ido-max-window-height 1)
(ido-mode 1)

(define-key ido-common-completion-map (kbd "C-n") #'ido-next-match)
(define-key ido-common-completion-map (kbd "C-p") #'ido-prev-match)

(global-set-key (kbd "C-x C-b") #'ibuffer)

(straight-use-package 'savehist)
(savehist-mode 1)

(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)

(straight-use-package 'helpful)
(require 'helpful)
(after 'helpful
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-c C-d") #'helpful-at-point)
  (global-set-key (kbd "C-h F") #'helpful-function)
  (global-set-key (kbd "C-h C") #'helpful-command))

(straight-use-package 'popwin)
(require 'popwin)
(popwin-mode 1)

(straight-use-package 'which-key)
(which-key-mode)

(straight-use-package 'org-download)
(require 'org-download)

(straight-use-package 'iedit)
(require 'iedit)

(straight-use-package 'wgrep)
(require 'wgrep)

(straight-use-package 'ripgrep)
(require 'ripgrep)

(straight-use-package 'org)
(straight-use-package 'visual-fill-column)

(require 'org)
(require 'org-tempo)

;; Properties should be inherited
(setq org-use-property-inheritance t)

(setq org-tags-column 0)
(setq org-image-actual-width 250)

(defun oh/org-mode ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1)
  (setq visual-fill-column-width 140
        visual-fill-column-center-text t)
  (visual-fill-column-mode)
  (auto-fill-mode)
  (setq org-download-method 'directory)
  (setq org-download-image-dir "./resources")
  (org-download-enable))

(defun oh/org-font ()
  (let* ((variable-tuple
          (cond ((x-list-fonts "ETBembo")         '(:font "ETBembo"))
                ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
                ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
                ((x-list-fonts "Verdana")         '(:font "Verdana"))
                ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
                (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
         (base-font-color     (face-foreground 'default nil 'default))
         (headline           `(:inherit default :weight bold )))

    (custom-theme-set-faces
     'user
     `(org-level-8 ((t (,@headline ,@variable-tuple))))
     `(org-level-7 ((t (,@headline ,@variable-tuple))))
     `(org-level-6 ((t (,@headline ,@variable-tuple))))
     `(org-level-5 ((t (,@headline ,@variable-tuple))))
     `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1))))
     `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.1))))
     `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.1))))
     `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.1))))
     `(org-document-title ((t (,@headline ,@variable-tuple :height 2.0 :underline nil))))))
  (custom-theme-set-faces
   'user
   '(org-block			((t (:inherit fixed-pitch))))
   '(org-block-begin-line	((t (:inherit fixed-pitch))))
   '(org-code			((t (:inherit (shadow fixed-pitch)))))
   '(org-document-info		((t (:foreground "dark orange"))))
   '(org-document-info-keyword	((t (:inherit (shadow fixed-pitch)))))
   '(org-indent			((t (:inherit (org-hide fixed-pitch)))))
   '(org-link			((t (:foreground "royal blue" :underline t))))
   '(org-meta-line		((t (:inherit (font-lock-comment-face fixed-pitch)))))
   '(org-property-value		((t (:inherit fixed-pitch))) t)
   '(org-special-keyword	((t (:inherit (font-lock-comment-face fixed-pitch)))))
   '(org-table			((t (:inherit fixed-pitch :foreground "#83a598"))))
   '(org-tag			((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
   '(org-verbatim		((t (:inherit (shadow fixed-pitch)))))))

(after 'org
  (when window-system 
    (oh/org-font)))

(add-hook 'org-mode-hook #'oh/org-mode)
(setq auto-mode-alist (append auto-mode-alist '(("\\.org\\'" . org-mode))))

(straight-use-package 'haskell-mode)
(require 'haskell-mode)
(setq exec-path (cons "/Users/seungheonoh/.ghcup/bin" exec-path))
(setenv "PATH" (concat (getenv "PATH") ":/Users/seungheonoh/.ghcup/bin"))

(eval-after-load 'haskell-mode '(progn
  (define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-or-reload)
  (define-key haskell-mode-map (kbd "C-c C-z") 'haskell-interactive-switch)
  (define-key haskell-mode-map (kbd "C-c C-n C-t") 'haskell-process-do-type)
  (define-key haskell-mode-map (kbd "C-c C-n C-i") 'haskell-process-do-info)
  (define-key haskell-mode-map (kbd "C-c C-n C-c") 'haskell-process-cabal-build)
  (define-key haskell-mode-map (kbd "C-c C-n c") 'haskell-process-cabal)))

(setq auto-mode-alist (append auto-mode-alist '(("\\.hs\\'" . haskell-mode))))

(setq eshell-prompt-function
  (lambda ()
    (concat "Î» ")))

(setq eshell-prompt-regexp "Î» ")

(require 'ispell)
(setq ispell-program-name "hunspell")

(defun oh/fixspell (word)
  (let* ((prompt (format "[%s] in %s: " word (or ispell-local-dictionary ispell-dictionary "Default")))
         (poss (progn
                 (ispell-set-spellchecker-params) 
                 (ispell-accept-buffer-local-defs)
                 (setq poss (ispell--run-on-word word)))))
    (cond
     ((null poss)
      (progn (message "Error checking word %s" (funcall ispell-word-format-function word)) ""))
     ((or (eq poss t) (stringp poss))
      (progn (message "%s is correct" (funcall ispell-format-word-function word)) word))
     (t (completing-read prompt (nth 2 poss))))))

(defun oh/fixspell-at-point ()
  (interactive)
  (let* ((word (thing-at-point 'word))
         (selected (oh/fixspell word)))
    (when (not (eq word selected))
      (backward-word)
      (kill-word 1)
      (setq kill-ring (cdr kill-ring))
      (insert selected))))

(global-set-key (kbd "C-c w s") 'oh/fixspell-at-point)

(straight-use-package 'magit)

(straight-use-package '0x0)

(straight-use-package 'yasnippet)
(yas-global-mode 1)

(straight-use-package 'modus-themes)
(modus-themes-load-operandi)
