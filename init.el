(require `tramp)
(require 'package)
;; Add the original Emacs Lisp Package Archive
(add-to-list 'package-archives
             '("elpa" . "http://tromey.com/elpa/"))

;; Add the user-contributed repository
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)


(when (not package-archive-contents)
  (package-refresh-contents))

;; Add in your own as you wish:
(defvar my-packages '(starter-kit
		      starter-kit-lisp
		      starter-kit-bindings
		      starter-kit-ruby
                      starter-kit-js
		      starter-kit-eshell
                      yasnippet-bundle
                      color-theme
                      projectile
                      helm
                      helm-projectile
                      auto-complete
                      emmet-mode
                      ac-emmet
                      expand-region
                      jedi
                      markdown-mode
                      feature-mode
                      clojure-mode
                      clojurescript-mode
                      flymake-jshint
                      flymake-cursor
                      flymake-ruby
                      scss-mode
                      less-css-mode
                      web-mode
                      virtualenv
                      ;; rinari
                      rvm
                      color-theme-sanityinc-tomorrow)
  "A list of packages to ensure are installed at launch.")

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))


(require 'color-theme)
;; (load-file "~/.emacs.d/color-theme-twilight.el")

(require 'color-theme-sanityinc-tomorrow)
(color-theme-sanityinc-tomorrow-eighties)
;; (set-face-font 'default "-unknown-DejaVu Sans Mono-normal-normal-normal-*-14-*-*-*-m-0-iso10646-1")

;; flymake global config
(require 'flymake-cursor)

;; auto-complete config
(require 'auto-complete-config)
(ac-config-default)

;; expand-region config
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; CSS autocomplete inifinite loop hack
(add-to-list 'ac-css-value-classes
	     '(border-width "thin" "medium" "thick" "inherit"))

;; emmet config
;; remove bind for expand line to C-j used for newline
(define-key emmet-mode-keymap (kbd "C-j") nil)
(define-key emmet-mode-keymap (kbd "C-i") 'emmet-expand-line)

;; Webmode config
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(setq web-mode-markup-indent-offset 2)
(setq web-mode-css-indent-offset 2)
(setq web-mode-code-indent-offset 2)
(setq web-mode-ac-sources-alist
  '(("css" . (ac-source-css-property))
    ("html" . (ac-source-words-in-buffer ac-source-abbrev))))

(setq web-mode-engines-alist
      '(("django"    . "\\.html\\'"))
)


;; projectile config
(require 'projectile)
(projectile-global-mode)
;; Dangerous
;; (setq projectile-enable-caching t)

;; helm config
(require 'helm-config)
(global-set-key (kbd "C-c h") 'helm-projectile)

(global-auto-revert-mode t)

;; Python config
(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "epylint" (list local-file))))

  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init)))

;; Auto-start flymake-mode when you go into python-mode
(add-hook 'python-mode-hook
          '(lambda ()
             (flymake-mode)))

;; JS config
(add-hook 'js-mode-hook
          '(lambda ()
             (setq js-indent-level 2)
             (setq tab-width 4)
             )
          )



(require 'flymake-jshint)
(add-hook 'js-mode-hook
     (lambda () (flymake-mode t)))

;; css/less Config
(add-hook 'less-css-mode
          '(lambda () (setq css-indent-offset 2)))


;; Ruby config
(require 'flymake-ruby)
(add-hook 'ruby-mode-hook 'flymake-ruby-load)

;; feature-mode config
(require 'feature-mode)

(add-to-list 'auto-mode-alist '("\.feature$" . feature-mode))

(add-hook 'feature-mode-hook
          '(lambda ()
             (setq feature-indent-level 4)

             )
          )

;; path configuration
(setenv "PATH" (concat "/home/pablo/bin:" (getenv "PATH")))


(defun move-text-internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
        (exchange-point-and-mark))
    (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (let ((column (current-column)))
      (beginning-of-line)
      (when (or (> arg 0) (not (bobp)))
        (forward-line)
        (when (or (< arg 0) (not (eobp)))
          (transpose-lines arg))
        (forward-line -1))
      (move-to-column column t)))))

(defun move-text-down (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines down."
  (interactive "*p")
  (move-text-internal arg))

(defun move-text-up (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines up."
  (interactive "*p")
  (move-text-internal (- arg)))

(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)
