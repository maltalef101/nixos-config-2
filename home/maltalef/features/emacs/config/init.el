;;; init.el -- Emacs config
;-*- Emacs-Lisp -*-
;-*- lexical-binding: t; -*-

;;; === Custom functions ===
(defun memacs/display-startup-time ()
  (message "[STARTUP] Emacs loaded in %s with %d garbage collections."
	   (format "%.2f seconds"
		   (float-time
		    (time-subtract after-init-time before-init-time)))
	   gcs-done))

(defun memacs/kill-all-buffers ()
	(interactive)
	(mapcar 'kill-buffer (buffer-list))
	(delete-other-windows))

(defun memacs/short-indent ()
  (setq indent-tabs-mode nil)
  (setq tab-width 2))

(defun memacs/evil-hook ()
	 (dolist (mode '(custom-mode
		  eshell-mode
		  git-rebase-mode
		  erc-mode
		  circe-server-mode
		  circe-chat-mode
		  circe-query-mode
		  sauron-mode
		  term-mode))
	   (add-to-list 'evil-emacs-state-modes mode)))

(defun memacs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

;;; === Global settings ===
(menu-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(scroll-bar-mode -1)
(tab-bar-mode 1)

(setq visible-bell t)

(setq-default truncate-lines nil)
(setq truncate-partial-width-windows nil)

(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)

(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

(fset 'yes-or-no-p 'y-or-n-p) ;; Sensible prompts

;; Vim like scrolling
(setq scroll-step 1)
(setq scroll-margin 10)
(setq scroll-conservatively 101)
(setq auto-window-vscroll nil)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-follow-mouse 't)

;; Line/column numbers
(column-number-mode)
(global-display-line-numbers-mode)
(setq-default display-line-numbers-type 'relative)
(dolist (mode '(term-mode-hook
				shell-mode-hook
				eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Directories and files
(setq user-emacs-directory "~/.config/emacs")

; Backups stay in a confined directory
(setq backup-directory-alist `(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory))))

; Auto-saves also stay in a confined directory
(setq auto-save-list-file-prefix (expand-file-name "tmp/auto-saves/sessions/" user-emacs-directory)
      auto-save-file-name-transforms `((".*" ,(expand-file-name "tmp/auto-saves/" user-emacs-directory) t)))

; Projectile
(setq projectile-known-projects-file (expand-file-name "tmp/projectile-bookmarks.eld" user-emacs-directory)
      lsp-session-file (expand-file-name "tmp/.lsp-session-v1" user-emacs-directory))

; custom.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

;; Indentation
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default evil-shift-width tab-width) ;; Use with '<' and '>' keys

;; Parens
(show-paren-mode)
(electric-pair-mode)
(setq show-paren-delay 0)

;; Bindings
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-set-key (kbd "C-c K") 'memacs/kill-all-buffers)

;;; === PACKAGES ===
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("elpa" . "http://elpa.gnu.org/packages/")
			 ("elpy" . "https://jorgenschaefer.github.io/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-hide-results t))

(use-package diminish)

(use-package no-littering)

(use-package all-the-icons)

(use-package rainbow-delimiters
  :hook (prog-mode. rainbow-delimiters-mode))

(use-package unicode-fonts
  :config
  (unicode-fonts-setup))

(use-package doom-themes
  :init
  (setq doom-themes-enable-bold t
		doom-themes-enable-italic t)
  :config
  (load-theme 'doom-gruvbox t))

(defun memacs/org-latex-snippets ()
  "Activate LaTeX snippets in Org mode."
  (yas-activate-extra-mode 'latex-mode))

(use-package org
    :mode (("\\.org$" . org-mode))
    :ensure org-plus-contrib
	:hook (org-mode . memacs/org-latex-snippets))

(use-package tex
	:ensure nil
	:init
	(setq TeX-auto-save t)
	(setq TeX-parse-self t)
	)

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump t)
  (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode 1)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :diminish evil-collection-unimpaired-mode
  :config
  (evil-collection-init))

(use-package undo-fu)
(use-package undo-fu-session
  :config
  (global-undo-fu-session-mode))

(use-package ws-butler
  :diminish ws-butler-mode
  :hook ((text-mode prog-mode) . ws-butler-mode))

(use-package swiper
  :commands (swiper))

(use-package ivy
  :diminish ivy-mode
  :bind(("C-s" . swiper)
	:map ivy-minibuffer-map
	("TAB" . ivy-alt-done)
	("C-l" . ivy-alt-done)
	("C-j" . ivy-next-line)
	("C-k" . ivy-previous-line)
	:map ivy-switch-buffer-map
	("C-k" . ivy-previous-line)
	("C-l" . ivy-done)
	("C-d" . ivy-switch-buffer-kill)
	:map ivy-reverse-i-search-map
	("C-k" . ivy-previous-line)
	("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :diminish ivy-rich-mode
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :diminish counsel-mode
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-switch-buffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/dev")
    (setq projectile-project-search-path '("~/dev")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package which-key
  :diminish which-key-mode
  :custom
  (which-key-idle-delay 0.3)
  :config
  (which-key-mode))

(use-package general
  :config
  (general-create-definer memacs/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC"))

(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "up")
  ("k" text-scale-decrease "down")
  ("f" nil "finished" :exit t))

(memacs/leader-keys
    "t" '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
	"ts" '(hydra-text-scale/body :which-key "scale text"))

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :config
  (setq magit-status-buffer-switch-function 'switch-to-buffer))

(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.05))

;; Dired
(use-package dired-single)

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump)
	 ("C-x d" . dired-single-magic-buffer))
  :custom ((dired-listing-switches "-agoh --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer
    "RET" 'dired-single-buffer
    [remap dired-find-file] 'dired-single-buffer
    [remap dired-up-directory] 'dired-single-up-directory))

(use-package diredfl
  :hook (dired-mode . diredfl-mode))

(use-package dired-open
  :after dired
  :config
;;  (add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "sxiv")
				("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :after dired
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

;;; === LSP AND LANGUAGES ===
(use-package tree-sitter
  :diminish tree-sitter-mode
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
(use-package tree-sitter-langs)

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . memacs/lsp-mode-setup)
  :init
  (setq lsp-prefer-flymake nil)
  (setq-default lsp-keymap-prefix "C-c c l")
  :custom
  (lsp-prefer-capf)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analizer-display-closure-return-type-hints t)
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :after lsp
  :custom
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-sideline-show-code-actions t)
  ;; (lsp-ui-sideline-update-mode "line")
  (lsp-ui-sideline-delay 0.2)
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-position at-point)
  )

(use-package lsp-ivy
  :after lsp)

(use-package flycheck)

(use-package company
  :diminish company-mode
  :bind
  (:map company-active-map
              ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package yasnippet
  :config
  (yas-reload-all)
  (yas-global-mode))
(use-package yasnippet-snippets)

;; == Language specific config ==

;; TS and JS
(use-package typescript-mode
  :mode "\\*.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 4))

(use-package js2-mode
  :hook (js2-mode . lsp-deferred)
  :config
  ;; Use js2-mode for Node scripts
  (setq js2-mode-show-strict-warnings nil)

  ;; (add-hook 'js2-mode-hook #'memacs/short-indent)
  ;; (add-hook 'json-mode-hook #'memacs/short-indent)
  )

;; Vue
(use-package vue-mode
  :mode "\\*.vue\\'"
  :hook (vue-mode . lsp-deferred)
  :config
  (add-hook 'mmm-mode-hook (lambda () (set-face-background 'mmm-default-submode face nil))))

;; Markdown
(use-package markdown-mode
  :mode "\\.md\\'"
  :hook (markdown-mode . auto-fill-mode))

;; Rust
(use-package rustic
  :ensure
  ;; :bind (:map rustic-mode-map
  ;;   		  ("M-j" . lsp-ui-imenu)
  ;;   		  ("M-?" . lsp-find-references)
  ;;   		  ("C-c C-c l" . flycheck-list-errors)
  ;;   		  ("C-c C-c a" . lsp-execute-code-action)
  ;;   		  ("C-c C-c r" . lsp-rename)
  ;;   		  ("C-c C-c q" . lsp-workspace-restart)
  ;;   		  ("C-c C-c Q" . lsp-workspace-shutdown)
  ;;   		  ("C-c C-c s" . lsp-rust-analyzer-status))
  :bind (("<f6>" . rustic-format-buffer))
  :custom
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  :config
  (require 'lsp-rust)
  (setq lsp-rust-analyzer-completion-add-call-parenthesis nil)
  (setq rustic-format-on-save nil))

;; C
(use-package c-mode
  :ensure nil
  :hook ((c-mode c++-mode objc-mode cuda-mode) . lsp))

;; Java
(use-package lsp-java
  :after lsp)
(use-package java
  :ensure nil
  :hook (java-mode . lsp-deferred)
  :after lsp-java)
