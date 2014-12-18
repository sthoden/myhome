;;-*-Emacs-Lisp-*-
;; .emacs.d/init.el
;;

(add-to-list 'load-path "~/.emacs.d")

;;________________________________________________________________
;;
;; Turn off the annoying crap immediately
;;________________________________________________________________

(menu-bar-mode 0)
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(blink-cursor-mode -1)
(setq backup-inhibited t)
(setq auto-save-default nil)
(setq inhibit-startup-message t)
;; (setq initial-scratch-message nil)
(setq wdired-allow-to-change-permissions t)
(add-hook 'dired-mode-hook 'toggle-truncate-lines)

;; If we read a compressed file, uncompress it on the fly:
;; (this works with .tar.gz and .tgz file as well)
(auto-compression-mode 1)

;; Permanent display of line and column numbers is handy.
(setq-default line-number-mode 't)
(setq-default column-number-mode 't)

;; Highlight the marked region.
(setq-default transient-mark-mode t)


;;________________________________________________________________
;;
;;    Font lock
;;________________________________________________________________

;; Use font-lock everywhere.
(global-font-lock-mode t)

;; We have CPU to spare; highlight all syntax categories.
(setq font-lock-maximum-decoration t)

;; It is much more pleasant and less tiring to use a dark background.
(set-foreground-color "white")
(set-background-color "black")

;; Set cursor and mouse colours:
(set-cursor-color "yellow")
(set-mouse-color "white")


;;________________________________________________________________
;;
;;    Compilation
;;________________________________________________________________

(setq compile-command "mvn -q package") 
;; scroll the *compilation* buffer window as output appears. 
(setq compilation-scroll-output t) 
;; (setq compilation-window-height 20)
(setq compile-auto-highlight t)


(add-hook 'java-mode-hook 'electric-pair-mode)
;;(add-hook 'java-mode-hook (lambda ()
;;                            (setq fill-column 80)
;;                            (electric-pair-mode)))
(add-to-list 'auto-mode-alist '("\\.java$" . java-mode))


;;________________________________________________________________
;;
;;    Aquamacs stuff
;;________________________________________________________________

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aquamacs-additional-fontsets nil t)
 '(aquamacs-customization-version-id 300 t)
 '(aquamacs-tool-bar-user-customization nil t)
 '(emulate-mac-german-keyboard-mode t)
 '(ns-tool-bar-display-mode (quote both) t)
 '(ns-tool-bar-size-mode (quote regular) t)
 '(visual-line-mode nil t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
