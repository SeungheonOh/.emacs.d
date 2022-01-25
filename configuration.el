(setq gc-cons-threshold 10000000000)
(setq exec-path (cons "/opt/homebrew/bin" exec-path))
(setq exec-path (cons "/usr/local/bin" exec-path))
(setq exec-path (cons "/Users/SeungheonOh/bin" exec-path))
(setq exec-path (cons "/Library/TeX/texbin" exec-path))
(setenv "PATH"  (concat (getenv "PATH") ":/Library/TeX/texbin" ))
(setenv "PATH"  (concat (getenv "PATH") ":/usr/local/bin" ))
(setenv "PATH"  (concat (getenv "PATH") ":/opt/homebrew/bin" ))
  (setenv "PATH"  (concat (getenv "PATH") ":/Users/SeungheonOh/bin" ))

(defun oh/startup-time ()
  (message "Loaded in %s | %d garbages collected"
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done))
(add-hook 'emacs-startup-hook #'oh/startup-time)

;; depopulate minor mode 
;; no need for obvious stuffs
(setq minor-mode-supress-alist
      '((eldoc-mode	  "")
        (which-key-mode "") 
        (gcmh-mode	  "")
        ))

(defun oh/depopulate-minor ()
  (dolist (mode minor-mode-supress-alist)
    (let ((minor (assq (car mode) minor-mode-alist)))
      (when minor
        (setcdr minor (cdr mode))))))

;;(add-hook 'after-change-major-mode-hook #'oh/depopulate-minor)
(add-hook 'after-change-major-mode-hook
          (lambda () (setq minor-mode-alist '())))

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
(global-set-key [f5] #'recompile)

(global-set-key (kbd "C-c a") (lambda () (interactive) (org-agenda nil "w")))

(setq default-directory "~")
(setq visible-bell t)
(setq ring-bell-function (lambda ()
                           (invert-face 'mode-line)
                           (run-with-timer 0.05 nil #'invert-face 'mode-line)))
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))	;; cancer cured 2
(setq inhibit-startup-message t)				;; remove start message
(scroll-bar-mode -1)						;; remove scroll bar
(tool-bar-mode -1)						;; remove tool bar
(tooltip-mode -1)						;; remove tooltip
(set-fringe-mode '(15 . 0))					;; define fringes
(defalias 'yes-or-no-p 'y-or-n-p)				;; cancer cured
(hl-line-mode) 

(set-face-attribute 'default nil :font "Roboto Mono" :height 240)

(custom-theme-set-faces
 'user
 '(variable-pitch ((t (:family "ETBembo" :height 250))))
 '(fixed-pitch ((t ( :family "Roboto Mono" :height 240)))))
;; line numbers
(column-number-mode)
(global-display-line-numbers-mode t)

(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                xwidget-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq redisplay-dont-pause t
      scroll-margin 1
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)

(defvar bootstrap-version)
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

(straight-use-package 'paredit)

(straight-use-package 'multiple-cursors)
(require 'multiple-cursors)

(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

(straight-use-package 'gcmh)
(gcmh-mode 1)

(straight-use-package 'selectrum)

  (require 'selectrum)
  (setq completion-styles '(orderless))
  (selectrum-mode +1)
(after 'selectrum
  (define-key selectrum-minibuffer-map (kbd "C-j") #'selectrum-next-candidate)
  (define-key selectrum-minibuffer-map (kbd "C-k") #'selectrum-previous-candidate)
  (define-key selectrum-minibuffer-map (kbd "C-f") #'selectrum-next-page)
  (define-key selectrum-minibuffer-map (kbd "C-b") #'selectrum-previous-page))

(straight-use-package 'orderless)
(setq orderless-skip-highlighting (lambda () selectrum-is-active))
(setq selectrum-highlight-candidates-function #'orderless-highlight-matches)

(straight-use-package 'consult)

(require 'consult)
(global-set-key (kbd "C-x C-b") #'consult-buffer)
(global-set-key (kbd "C-c s") #'consult-line)
(global-set-key (kbd "C-c i") #'consult-imenu)
(global-set-key (kbd "C-c r") #'consult-ripgrep)
(after 'consult
  (setq consult-project-root-function
        (lambda ()
          (when-let (project (project-current))
            (car (project-roots project))))))

(defvar consult--source-eshell
  `( :name "Eshell"
     :narrow ?s
     :category buffer
     :state ,#'consult--buffer-state
     :items ,(lambda ()
               (seq-filter (lambda (b)
                             (string-match
                              (format oh/eshell-bufname-format ".+") b))
                           (mapcar #'buffer-name (buffer-list))))))

(add-to-list 'consult-buffer-sources 'consult--source-eshell 'append)

(straight-use-package 'marginalia)

  (require 'marginalia)
  (marginalia-mode)
(after 'marginalia
  (define-key minibuffer-local-map (kbd "M-A") #'marginalia-cycle)
  (define-key selectrum-minibuffer-map (kbd "M-A") #'marginalia-cycle))

(straight-use-package 'embark)
(require 'embark)
(after 'embark
(setq prefix-help-command #'embark-prefix-help-command)
(setq embark-indicators '(embark-minimal-indicator
                            embark-isearch-highlight-indicator))
(global-set-key (kbd "C-h B") #'embark-bindings)
(global-set-key (kbd "C-;") #'embark-act)
(global-set-key (kbd "C-:") #'embark-dwim))

(straight-use-package 'embark-consult)
(add-hook 'embark-collect-mode #'consult-preview-at-point-mode)

(straight-use-package 'savehist)

(savehist-mode 1)

(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)

(straight-use-package 'corfu)
(straight-use-package 'cape)

(setq corfu-auto t)
(setq corfu-auto-delay 0.3)
(setq corfu-quit-at-boundary nil)
(corfu-global-mode)

(add-to-list 'completion-at-point-functions #'cape-file)
(add-to-list 'completion-at-point-functions #'cape-tex)
(add-to-list 'completion-at-point-functions #'cape-dabbrev)
(add-to-list 'completion-at-point-functions #'cape-keyword)
(add-to-list 'completion-at-point-functions #'cape-sgml)
(add-to-list 'completion-at-point-functions #'cape-rfc1345)
(add-to-list 'completion-at-point-functions #'cape-abbrev)
(add-to-list 'completion-at-point-functions #'cape-ispell)
(add-to-list 'completion-at-point-functions #'cape-dict)
(add-to-list 'completion-at-point-functions #'cape-symbol)
(add-to-list 'completion-at-point-functions #'cape-line)

(straight-use-package 'helpful)
(require 'helpful)
(after 'helpful
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-c C-d") #'helpful-at-point)
  (global-set-key (kbd "C-h F") #'helpful-function)
  (global-set-key (kbd "C-h C") #'helpful-command))

(straight-use-package 'which-key)
(which-key-mode)

(straight-use-package 'aggressive-indent)

(straight-use-package 'popper)

(require 'popper)
(setq popper-reference-buffers
      '("\\*Messages\\*"
        "Output\\*$"
        "\\*Async Shell Command\\*"
        helpful-mode
        help-mode
        haskell-interactive-mode
        inferior-python-mode
        ))
(after 'popper 
  (global-set-key (kbd "C-c p") 'popper-toggle-latest)
  (global-set-key (kbd "C-c o") 'popper-cycle)
  (global-set-key (kbd "C-c P") 'popper-toggle-type)
  (popper-mode +1)
  (popper-echo-mode +1))

(straight-use-package 'alert)
(setq alert-default-style 'notifier)

(straight-use-package 'org-download)
(require 'org-download)

(straight-use-package 'org)
(straight-use-package 'visual-fill-column)

(require 'org)
(require 'org-tempo)

;; Properties should be inherited
(setq org-use-property-inheritance t)

;; Put logs inot drawer
(setq org-log-into-drawer t)

;; custom TODO keywords
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "WORKING(w)" "|" "DONE(d!)")))

(setq org-todo-keyword-faces
      '(;;("TODO" . "red")
        ;;("DONE" . "dark green")
        ("NEXT" . "orange")
        ("WORKING" . "purple")))

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
  (setq org-download-screenshot-method "/opt/homebrew/bin/pngpaste")
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
  ;; (custom-theme-set-faces
  ;;  'user
  ;;  '(variable-pitch ((t (:family "ETBembo" :height 210))))
  ;;  '(fixed-pitch ((t ( :family "BQN386 Unicode" :height 200)))))
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

(require 'ox-beamer)

(setq org-capture-templates
      `())

(straight-use-package 'org-roam)
(straight-use-package 'org-roam-ui)
(require 'org-roam)

(setq org-roam-directory "~/Roam")
(setq org-roam-dailies-directory "daily/")
(setq org-roam-completion-everywhere t)


(org-roam-db-autosync-mode)

(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.33)
               (window-height . fit-window-to-buffer)))

(setq org-roam-mode-section-functions
      (list #'org-roam-backlinks-section
            #'org-roam-reflinks-section
            #'org-roam-unlinked-references-section))

;; (setq org-roam-capture-templates
;;       '(("d" "default" plain
;; 	 "%?"
;; 	 :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
;; 	 :unnarrowed t)))

;; specifically specificly tagged nodes
(defun oh/org-roam-nodes-by-tag (tag)
  (mapcar #'org-roam-node-file
          (seq-filter (lambda (n)
                        (seq-reduce
                         (lambda (a b) (or a b))
                         (mapcar (lambda (e) (member e (org-roam-node-tags n))) tag)
                         nil))
                      (org-roam-node-list))))

(defun oh/org-roam-agenda-generate-category ()
  (dolist (file org-agenda-files)
    (find-file file)
    (let ((title (org-roam-get-keyword "title")))
      (org-roam-set-keyword "category" title))
    (save-buffer)
    (kill-buffer)))

(defun org-roam-node-rename ()
  (interactive)
  (unless (org-roam-buffer-p) (error "Not in an org-roam buffer."))
  (save-some-buffers t)
  (let* ((id (org-entry-get (point) "ID"))
         (node (org-roam-node-from-id id))
         (title (org-roam-get-keyword "title"))
         (newtitle (read-string "New title: " title)))
    (when (null id) (error "Failed to fetch ID"))
    (when (org-roam-node-from-title-or-alias newtitle)
      (error (format "Node %s already exists" newtitle)))

    ;; Set new title
    (org-roam-set-keyword "title" newtitle) 
    (save-buffer)

    ;; Rename current buffer
    (let* ((orif (buffer-file-name))
           (dir (file-name-directory orif))
           (file (file-name-nondirectory orif))
           (titlenoslash (s-replace-regexp "/" "_" (downcase newtitle)))
           (newreg (format "\\1-%s.org" titlenoslash))
           (nfile (s-replace-regexp "\\([0-9]+\\)\\-.+\.org" newreg file))
           (newfname (concat dir nfile)))
      (progn
        (rename-file orif newfname)
        (rename-buffer newfname)
        (set-visited-file-name newfname)
        (set-buffer-modified-p nil)))

    ;; Modify Links
    (let* ((bkl (org-roam-backlinks-get (org-roam-node-from-id id)))
           (files (mapcar (lambda (b) (org-roam-node-file (org-roam-backlink-source-node b))) bkl))
           (reg (format "\\[\\[id:%s\\]\\[[^][]+\\]\\]" id))
           (newlink (format "[[id:%s][%s]]" id newtitle)))
      (dolist (file files)
        (find-file file)
        (goto-char (point-min))
        (while (re-search-forward reg nil t)
          (replace-match newlink))
        (save-buffer)
        (kill-buffer (current-buffer))))))

(defun org-roam-node-insert-immediate (arg &rest args)
  (interactive "P")
  (let ((args (cons arg args))
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(defun oh/org-roam-copy-todo-to-today ()
  (let ((org-refile-keep t) ;; Set this to nil to delete the original!
        (org-roam-dailies-capture-templates
         '(("t" "tasks" entry "%?"
            :if-new (file+head+olp "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n" ("Finished!")))))
        (org-after-refile-insert-hook #'save-buffer)
        today-file
        pos)
    (save-window-excursion
      (org-roam-dailies-goto-today)
      (save-buffer)
      (setq today-file (buffer-file-name))
      (setq pos (point)))

    ;; Only refile if the target file is different than the current file
    (unless (equal (file-truename today-file)
                   (file-truename (buffer-file-name)))
      (org-refile nil nil (list "Finished!" today-file nil pos)))))

(add-to-list 'org-after-todo-state-change-hook
             (lambda ()
               (when (equal org-state "DONE")
                 (oh/org-roam-copy-todo-to-today))))

(after 'org-roam
  (global-set-key (kbd "C-c n l") #'org-roam-buffer-toggle)
  (global-set-key (kbd "C-c n f") #'org-roam-node-find)
  (global-set-key (kbd "C-c n i") #'org-roam-node-insert)
  (global-set-key (kbd "C-c n I") #'org-roam-node-insert-immediate)
  (global-set-key (kbd "C-c n r") #'org-roam-node-rename)
  (define-key org-mode-map (kbd "C-M-i") #'completion-at-point))

(require 'org-agenda)

(defun oh/update-agenda-files ()
  (setq org-agenda-files (oh/org-roam-nodes-by-tag '("school" "project" "task"))))

(add-hook 'org-agenda-mode-hook (lambda ()
                                  (oh/update-agenda-files)
                                  (oh/org-roam-agenda-generate-category)))

(setq org-agenda-custom-commands
      '(("i" "In Progress" todo "WORKING")
        ("d" "Done" todo "DONE")
        ("a" "Academics" tags-todo "+school")
        ("A" "All" todo)
        ("p" "Projects" tags-todo "+project")

        ("w" "Weeks"
         ((todo "TODO")
          (agenda ""
                  ((org-agenda-overriding-header "Overview")
                   (org-agenda-start-on-weekday nil)
                   (org-agenda-span 14)
                   (org-agenda-start-day "-3d")))))
        ("t" "Today"
         ((todo "TODO")
          (agenda ""
                  ((org-agenda-overriding-header "Overview")
                   (org-agenda-span 1)))))

        ))

(straight-use-package 'ox-reveal)
(straight-use-package 'htmlize)
(require 'ox-reveal)
(require 'htmlize)

(straight-use-package 'lsp-mode)
(straight-use-package 'lsp-ui)

(setq lsp-keymap-prefix "C-c l")

(straight-use-package 'haskell-mode)
(straight-use-package 'lsp-haskell)

(require 'haskell-mode)
(setq lsp-haskell-server-path "/Users/seungheonoh/.ghcup/bin/haskell-language-server-wrapper")
(setq exec-path (cons "/Users/seungheonoh/.ghcup/bin" exec-path))
(setenv "PATH" (concat (getenv "PATH") ":/Users/seungheonoh/.ghcup/bin"))
(setq haskell-process-type 'stack-ghci)

(defun oh/reload-interactive-haskell ()
  (when (and (buffer-list)
             (eq (buffer-local-value 'major-mode
                                     (current-buffer))
                 'haskell-mode))
    (haskell-process-reload)))

(define-key haskell-mode-map (kbd "C-c C-c") #'oh/reload-interactive-haskell)

(add-hook 'haskell-mode-hook
          (lambda ()
            (add-hook 'after-save-hook #'oh/reload-interactive-haskell)))
(add-hook 'haskell-mode-hook #'interactive-haskell-mode)
(add-hook 'haskell-mode-hook #'lsp)
(add-hook 'haskell-literate-mode-hook #'lsp)

(setq auto-mode-alist (append auto-mode-alist '(("\\.hs\\'" . haskell-mode))))

;; (load-file (let ((coding-system-for-read 'utf-8))
;;                (shell-command-to-string "/opt/homebrew/bin/agda2-mode locate")))
;; setq auto-mode-alist (append auto-mode-alist '(("\\.agda\\'" . agda2-mode))))

(straight-use-package 'web-mode)

(load
   "/Users/seungheonoh/.opam/default/share/emacs/site-lisp/tuareg-site-file")

(straight-use-package 'tide)

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1))
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)

(load "/Users/seungheonoh/.emacs.d/others/koka-mode.el")

(defun eshell/c ()
  (let ((inhibit-read-only t))
    (erase-buffer)))
(defun eshell/v (&rest args)
  (apply #'find-file args))
(defun eshell/magit ()
  (magit-status))

(setq eshell-prompt-function
  (lambda ()
    (concat "λ ")))

(setq eshell-prompt-regexp "λ ")

(setq oh/eshell-bufname-format "*eshell@[%s]*")

(defun oh/eshell-here ()
  (interactive)
  (let* ((parent (if (buffer-file-name)
                     (file-name-directory (buffer-file-name))
                   default-directory)) 
         (dir (car (last (split-string parent "/" t))))
         (name (format oh/eshell-bufname-format dir))
         (buf (get-buffer name)))
    (cond (buf (switch-to-buffer buf))
          (t (progn
               (eshell)
               (eshell/clear-scrollback)
               (rename-buffer name)
               (insert (concat "ls"))
               (eshell-send-input))))))

(defun oh/eshell-update-bufname ()
  "Updates the buffername according to the current directory
   When users tries to cd into directory that already has matching
   buffer, it will switch buffer. It guarantees that there are no eshell 
   buffers with duplicate directory"
  (let* ((dir (car (last (split-string (eshell/pwd) "/" t))))
         (name (format oh/eshell-bufname-format dir))
         (samebuf (get-buffer name)))
    (cond
     (samebuf (progn
                (rename-buffer "!") ;; buffer name should be altered temporarily 
                (eshell/cd "-")
                (switch-to-buffer name)))
     (t (rename-buffer name)))))

(setq eshell-scroll-to-bottom-on-input t)
(global-set-key (kbd "C-c !") 'oh/eshell-here)
(add-hook 'eshell-directory-change-hook #'oh/eshell-update-bufname)

(require 'ispell)
(setenv "DICPATH" (concat (getenv "HOME") "/Library/Spelling"))
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
      (oh/add-vocab selected)
      (backward-word)
      (kill-word 1)
      (setq kill-ring (cdr kill-ring))
      (insert selected))))

(defun oh/allwords ()
  (interactive)
  (let* ((currdic ispell-current-dictionary)
         (aff (cadr (assoc currdic ispell-hunspell-dict-paths-alist)))
         (dic (concat (file-name-sans-extension aff) ".dic"))
         (prompt (format "In %s: " currdic))
         (cmd (format "/opt/homebrew/bin/unmunch %s %s 2> /dev/null" dic aff))
         (choice (consult--read (split-string (shell-command-to-string cmd) "\n") :prompt prompt)))
    (insert choice)))

(defun oh/fixspell-insert (word)
  (interactive "sWord: ")
  (let* ((selected (oh/fixspell word)))
    (oh/add-vocab selected t)
    (insert selected)))

(defun oh/translate ()
  (interactive)
  (let* ((default (if (use-region-p)
                      (buffer-substring-no-properties
                       (region-beginning) (region-end))
                    (let ((word (thing-at-point 'word)))
                      (when word (substring-no-properties word)))))
         (wordsinbuf (delete-dups
                      (remove ""
                              (mapcar (lambda (s) (replace-regexp-in-string "[^a-zA-Z0-9-]" "" s))
                                      (split-string (downcase (buffer-string)))))))
         (word (completing-read "-> " wordsinbuf nil nil default)))
    (with-current-buffer (get-buffer-create "*Translate*")
      (read-only-mode -1)
      (erase-buffer)
      (insert (shell-command-to-string (format "trans :ko \"%s\"" word)))
      (goto-char (point-min))
      (read-only-mode t)
      (display-buffer (current-buffer))
      (setq imenu-generic-expression
            `(("Sections"
               ,(rx (and line-start (or "adjective"
                                        "interjection"
                                        "adverb"
                                        "noun"
                                        "verb"
                                        "Synonyms"
                                        "Examples"
                                        "See also")
                         line-end))0))))))

(defun oh/add-vocab (iword &optional bypass)
  (let* ((word (if bypass iword (oh/fixspell iword)))
         (vocabfile "~/vocab.org"))
    (unless (save-window-excursion
              (find-file vocabfile)
              (goto-char (point-min))
              (search-forward (concat "* " (capitalize word)) nil t))
      (let* ((translation (shell-command-to-string (format "trans -b :ko %s" word)))
             (definition (shell-command-to-string (format "trans -d %s" word)))
             (entry (format "* %s\n%s\n%s" (capitalize word) translation definition))
             (org-capture-templates `(("v" "vocab" entry (file ,vocabfile) ,entry
                                       :immediate-finish t))))        
        (org-capture nil "v")))))

(defun oh/new-vocab (word)
  (interactive "sWord:")
  (oh/add-vocab word))

(global-set-key (kbd "C-c w s") 'oh/fixspell-at-point)
(global-set-key (kbd "C-c w a") 'oh/allwords)
(global-set-key (kbd "C-c w i") 'oh/fixspell-insert)
(global-set-key (kbd "C-c w t") 'oh/translate)
(global-set-key (kbd "C-c w v") 'oh/new-vocab)

(straight-use-package 'ansi-color)
(require 'ansi-color)
(defun my/ansi-colorize-buffer ()
  (let ((buffer-read-only nil))
    (ansi-color-apply-on-region (point-min) (point-max))))
(add-hook 'compilation-filter-hook 'my/ansi-colorize-buffer)

(setq compilation-scroll-output t)
(push '("\\*compilation\\*" . (nil (reusable-frames . t))) display-buffer-alist)
(defadvice recompile (after recompile-advice activate) 
  (other-frame 1))

; from enberg on #emacs
(defun oh/compilation-autoclose (buf str)
  (if (null (string-match ".*exited abnormally.*" str))
      ;;no errors, make the compilation window go away in a few seconds
      (progn
        (run-at-time
         "1 sec" nil 'delete-windows-on
         (get-buffer-create "*compilation*"))
        (message "No Compilation Errors!"))))

(defun oh/compilation-open ()
  (interactive)
  (let ((buf (get-buffer "*compilation*")))
    (cond (buf (switch-to-buffer buf))
          (t (message "*compilation* not found")))))

(global-set-key (kbd "C-<f5>") #'oh/compilation-open)
(add-hook 'compilation-finish-functions #'oh/compilation-autoclose)

(defun oh/compile-in-other-frame ()
  (interactive)
  (let ((buf (get-buffer "*compilation*")))
    (cond (buf
           (clone-frame)
           (switch-to-buffer buf)
           (remove-hook 'compilation-finish-functions #'oh/compilation-autoclose)
           (other-frame -1))
          (t (message "*compilation* not found")))))

(straight-use-package 'magit)

(straight-use-package '0x0)

(straight-use-package 'yasnippet)
(yas-global-mode 1)

(straight-use-package 'powerthesaurus)

(straight-use-package 'elcord)
;;(elcord-mode)

(straight-use-package 'elfeed)
(setq elfeed-feeds
      '("https://news.ycombinator.com/rss"
        "https://seungheonoh.github.io/rss.xml"))

(straight-use-package 'mini-frame)
(custom-set-variables
 '(mini-frame-show-parameters
   '((top . 0.4)
     (width . 0.9)
     (left . 0.5))))
(mini-frame-mode)

(straight-use-package 'modus-themes)

;; Theme
(setq modus-themes-italic-constructs t
      modus-themes-bold-constructs nil
      modus-themes-org-blocks 'gray-background
      modus-themes-region '(bg-only no-extend))

(modus-themes-load-themes)
(modus-themes-load-operandi)

(defun oh/auto-tangle ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.emacs.d/configuration.org"))
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'oh/auto-tangle)))
