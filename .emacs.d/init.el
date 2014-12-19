;;=======================================================================
;; map-dir-list-into-load-path の定義
;;=======================================================================
;; rubikitch さん作のユーティリティ
;; http://d.hatena.ne.jp/rubikitch/20090609/1244484272
(defun add-to-load-path-recompile (dir)
  (add-to-list 'load-path dir)
  (let (save-abbrevs) (byte-recompile-directory dir)))

(defun map-dir-list-into-load-path (dir-lst)
  (mapcar #'(lambda (x)
              (add-to-load-path-recompile (expand-file-name x)))
               dir-lst))
;;
;;=======================================================================
;; パスを通す
;;=======================================================================
(defvar *dot-emacs-load-path-list*
  '("~/.emacs.d/auto-install"
    ;; ここで文字列でパスを通したいディレクトリを指定する
    ;; 例： "/i/want/to/make/a/path/to/the/directory"
    "~/.emacs.d/lisp"
    ))

(map-dir-list-into-load-path *dot-emacs-load-path-list*)

;;
;;=======================================================================
;; PATH Setting.
;;=======================================================================
;; より下に記述した物が PATH の先頭に追加されます
(dolist (dir (list
              "/sbin"
              "/usr/sbin"
              "/bin"
              "/usr/bin"
              "/opt/local/bin"
              "/sw/bin"
              "/usr/local/bin"
              (expand-file-name "~/.rvm/rubies/default/bin/")
              (expand-file-name "~/bin")
              (expand-file-name "~/.emacs.d/bin")
              ))
 ;; PATH と exec-path に同じ物を追加します
 (when (and (file-exists-p dir) (not (member dir exec-path)))
   (setenv "PATH" (concat dir ":" (getenv "PATH")))
   (setq exec-path (append (list dir) exec-path))))

;; shell の存在を確認
(defun skt:shell ()
  (or (executable-find "zsh")
      (executable-find "bash")
      (executable-find "cmdproxy")
      (error "can't find 'shell' command in PATH!!")))
;; Shell 名の設定
(setq shell-file-name (skt:shell))
(setenv "SHELL" shell-file-name)
(setq explicit-shell-file-name shell-file-name)


;;
;;=======================================================================
;; install-elisp
;;=======================================================================
(require 'install-elisp)
(setq install-elisp-repository-directory "~/.emacs.d/lisp")

;;
;;=======================================================================
;; auto-complete
;;=======================================================================
(require 'auto-complete)
(global-auto-complete-mode t)

;;
;;=======================================================================
;; dot-emacs-requirements-list
;;=======================================================================
(defvar *dot-emacs-requirements-list*
  '(cl
    session
    ;; 必要な機能があったらここに書き込む
    ;; 例： auto-install
    ))

(mapcar #'require *dot-emacs-requirements-list*)
;;
;;=======================================================================
;; フレームサイズ
;;=======================================================================
(defvar *dot-emacs-frame-setting-list*
  '((width . 90)                        ; フレームの幅
    (height . 49)                       ; フレームの高さ
    (top . 0)                           ; Y 表示位置
    (left . 340)                        ; X 表示位置
    (alpha . (100 85))))                ; 透明度

(loop for i in *dot-emacs-frame-setting-list*
   do (add-to-list 'initial-frame-alist i))

(setf default-frame-alist initial-frame-alist)
;;
;;=======================================================================
;; Misc
;;=======================================================================
(mouse-wheel-mode t)                        ;;ホイールマウス
(global-font-lock-mode t)                    ;;文字の色つけ
(setf line-number-mode t)                    ;;カーソルのある行番号を表示
(auto-compression-mode t)                    ;;日本語infoの文字化け防止
(set-scroll-bar-mode 'right)                    ;;スクロールバーを右に表示
(global-set-key "\C-z" 'undo)                    ;;UNDO
(setf frame-title-format                    ;;フレームのタイトル指定
      (concat "%b - emacs@" system-name))

(display-time)                            ;;時計を表示
;; (global-set-key "\C-h" 'backward-delete-char)            ;;Ctrl-Hでバックスペース
;; (setf make-backup-files nil)                    ;;バックアップファイルを作成しない
;; (setf visible-bell t)                        ;;警告音を消す
;; (setf kill-whole-line t)                    ;;カーソルが行頭にある場合も行全体を削除
;; (when (boundp 'show-trailing-whitespace)
;;   (setq-default show-trailing-whitespace t))    ;;行末のスペースを強調表示
;;
;;=======================================================================
;; 履歴の保存
;;=======================================================================
(add-hook 'after-init-hook 'session-initialize)
;;
;;=======================================================================
;; 最近使ったファイル
;;=======================================================================
(when (require 'recentf nil t)
  (setq recentf-max-saved-items 2000)
  (setq recentf-max-menu-items 20)
  (setq recentf-exclude '(".recentf"))
  (setq recentf-auto-cleanup 10)
  (setq recentf-auto-save-timer
        (run-with-idle-timer 30 t 'recentf-save-list))
  (recentf-mode 1))

;;
;;=======================================================================
;; リージョンに色を付ける
;;=======================================================================
(setf transient-mark-mode t)
;;
;;=======================================================================
;; 対応する括弧を光らせる
;;=======================================================================
(show-paren-mode)
;;
;;=======================================================================
;; C-c c で compile コマンドを呼び出す
;;=======================================================================
(define-key mode-specific-map "c" 'compile)
;;
;;=======================================================================
;; スクリプトを保存する時、自動的に chmod +x を行うようにする
;;=======================================================================
;; http://www.namazu.org/~tsuchiya/elisp/#chmod
;; を参照
(defun make-file-executable ()
  "Make the file of this buffer executable, when it is a script source."
  (save-restriction
    (widen)
    (if (string= "#!"
                  (buffer-substring-no-properties 1
                                                 (min 3 (point-max))))
        (let ((name (buffer-file-name)))
          (or (equal ?. (string-to-char
                          (file-name-nondirectory name)))
              (let ((mode (file-modes name)))
                (set-file-modes name (logior mode (logand
                                                   (/ mode 4) 73)))
                (message (concat "Wrote " name " (+x)"))))))))
(add-hook 'after-save-hook 'make-file-executable)
;;
;;=======================================================================
;; PHP-mode
;;=======================================================================
(load-library "php-mode")
(require 'php-mode)
;; php-mode タブ設定とか
(setq php-mode-force-pear t)
(add-hook 'php-mode-user-hook
          '(lambda ()
             (c-set-style "stroustrup")
             (setq tab-width 4)
             (setq c-basic-offset 4)
             (setq indent-tabs-mode nil)

             ;; php-completion
             (require 'php-completion)
             (php-completion-mode t)
             (define-key php-mode-map (kbd "C-o") 'phpcmp-complete)
             (when (require 'auto-complete nil t)
             (make-variable-buffer-local 'ac-sources)
             (add-to-list 'ac-sources 'ac-source-php-completion)
             (auto-complete-mode t))
))
(add-hook 'php-mode-hook
         (lambda ()
             (require 'php-completion)
             (php-completion-mode t)
             (define-key php-mode-map (kbd "C-o") 'phpcmp-complete)
             (when (require 'auto-complete nil t)
             (make-variable-buffer-local 'ac-sources)
             (add-to-list 'ac-sources 'ac-source-php-completion)
             (auto-complete-mode t)
             (subword-mode t))))
(add-to-list 'auto-mode-alist '("\\.tpl$" . php-mode))
(add-to-list 'auto-mode-alist '("\\.inc$" . php-mode))

;;
;;=======================================================================
;; web-mode
;;=======================================================================
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.twig\\'" . web-mode))
;;(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[gj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))

;;
;;=======================================================================
;; js2-mode
;;=======================================================================
;;(autoload 'js2-mode "js2" nil t)
;;(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
;(setq-default c-basic-offset 4)
;
;(when (load "js2" t)
;  (setq js2-cleanup-whitespace nil
;        js2-mirror-mode nil
;        js2-bounce-indent-flag nil)
;
;  (defun indent-and-back-to-indentation ()
;    (interactive)
;    (indent-for-tab-command)
;    (let ((point-of-indentation
;           (save-excursion
;             (back-to-indentation)
;             (point))))
;      (skip-chars-forward "\s " point-of-indentation)))
;  (define-key js2-mode-map "\C-i" 'indent-and-back-to-indentation)
;
;  (define-key js2-mode-map "\C-m" nil)
;
;  (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode)))

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))


;;
;;=======================================================================
;; Ruby-mode
;;=======================================================================
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))

(require 'rvm)
(rvm-use-default)

;; ruby-electric
(require 'ruby-electric)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode t)))
(setq ruby-electric-expand-delimiters-list nil)

;; ruby-block
(require 'ruby-block)
(ruby-block-mode t)
(setq ruby-block-highlight-toggle t)

;; indent
(setq ruby-deep-indent-paren-style nil)
(defadvice ruby-indent-line (after unindent-closing-paren activate)
  (let ((column (current-column))
        indent offset)
    (save-excursion
      (back-to-indentation)
      (let ((state (syntax-ppss)))
        (setq offset (- column (current-column)))
        (when (and (eq (char-after) ?\))
                   (not (zerop (car state))))
          (goto-char (cadr state))
          (setq indent (current-indentation)))))
    (when indent
      (indent-line-to indent)
      (when (> offset 0) (forward-char offset)))))

;; rcodetools
(require 'anything)
(require 'rcodetools)
(setq rct-find-tag-if-available nil)
(defun ruby-mode-hook-rcodetools ()
  (define-key ruby-mode-map "\M-\C-i" 'rct-complete-symbol)
  (define-key ruby-mode-map "\C-c\C-t" 'ruby-toggle-buffer)
  (define-key ruby-mode-map "\C-c\C-d" 'xmp)
  (define-key ruby-mode-map "\C-c\C-f" 'rct-ri))
(add-hook 'ruby-mode-hook 'ruby-mode-hook-rcodetools)

(require 'anything-rcodetools)
(setq rct-get-all-methods-command "PAGER='cat fri -l'")
;;(setq rct-get-all-methods-command "PAGER=less -R")
;; See docs
(define-key anything-map [(control ?;)] 'anything-execute-persistent-action)

;; For character encoding.
(set-language-environment       "Japanese")
(prefer-coding-system           'utf-8-unix)
(setq default-buffer-file-coding-system 'utf-8)
(setq coding-system-for-write   'utf-8)
(set-buffer-file-coding-system  'utf-8)
(set-terminal-coding-system     'utf-8)
(set-keyboard-coding-system     'utf-8)
(set-clipboard-coding-system    'utf-8)
(set-language-environment 'utf-8)
(set-default-coding-systems 'utf-8)


;;
;;=======================================================================
;; markdown-mode
;;=======================================================================
(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;;
;;=======================================================================
;; YAML-mode
;;=======================================================================
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

;;
;;=======================================================================
;; Slim-mode (slim is templating engine of ruby)
;;=======================================================================
(load-library "slim-mode")
(require 'slim-mode)

;;
;;=======================================================================
;; go-mode
;;=======================================================================
(add-to-list 'load-path "go-mode-load.el" t)
(require 'go-mode-load)


;;
;;=======================================================================
;; tramp
;;=======================================================================
(require 'tramp)

;;
;;=======================================================================
;; cua-mode
;;=======================================================================
;; cua-modeの矩形編集モードだけを使いたいので、
;; cua-modeをオンにしつつ、CUAキーバインドは無効にする
(cua-mode t)
(setq cua-enable-cua-keys nil)  ; CUAキーバインドを無効
(define-key global-map (kbd "C-j") 'cua-set-rectangle-mark) ;; C-returnを押すとC-jになってしまうため割り当てる

;;
;;=======================================================================
;; multi-term
;;=======================================================================
(when (require 'multi-term nil t)
  (setq multi-term-program shell-file-name)
  ;; emacsのキーを奪わせない
  (add-to-list 'term-unbind-key-list '"M-x")
  (add-hook 'term-mode-hook
            '(lambda()
              ;; C-tをウィンドウ切り替えにする
              (define-key term-raw-map (kbd "C-t") 'other-window)
              ;; C-hをterm内文字削除にする
              (define-key term-raw-map (kbd "C-h") 'term-send-backspace)
              ;; C-yをterm内ペースとにする
              (define-key term-raw-map (kbd "C-y") 'term-past)))
  ;; multi-term呼び出しキーバインド
  (global-set-key (kbd "C-c t") '(lambda()
                                   (interactive)
                                   (if (get-buffer "*terminal<1>*")
                                       ;; 既存のバッファがあれば使う
                                       (switch-to-buffer "*terminal<1>*")
                                   (multi-term))))
)

;;
;;=======================================================================
;; 分割した画面を入れ替える
;;=======================================================================
;;汎用機の SPF (mule みたいなやつ) には
;;画面を 2 分割したときの 上下を入れ替える swap screen
;;というのが PF 何番かにわりあてられていました。
(defun swap-screen()
  "Swap two screen,leaving cursor at current window."
  (interactive)
  (let ((thiswin (selected-window))
        (nextbuf (window-buffer (next-window))))
    (set-window-buffer (next-window) (window-buffer))
    (set-window-buffer thiswin nextbuf)))
(defun swap-screen-with-cursor()
  "Swap two screen,with cursor in same buffer."
  (interactive)
  (let ((thiswin (selected-window))
        (thisbuf (window-buffer)))
    (other-window 1)
    (set-window-buffer thiswin (window-buffer))
    (set-window-buffer (selected-window) thisbuf)))
;; ウィンドウ入れ替えキーの設定
(define-key global-map (kbd "C-c t") 'swap-screen)
(define-key global-map [f2] 'swap-screen)
(global-set-key [S-f2] 'swap-screen-with-cursor)


;;
;;=======================================================================
;; jklhでウィンドウのリサイズを可能にする
;;   http://d.hatena.ne.jp/mooz/20100119/p1より
;;=======================================================================
(defun window-resizer ()
  "Control window size and position."
  (interactive)
  (let ((window-obj (selected-window))
        (current-width (window-width))
        (current-height (window-height))
        (dx (if (= (nth 0 (window-edges)) 0) 1
              -1))
        (dy (if (= (nth 1 (window-edges)) 0) 1
              -1))
        action c)
    (catch 'end-flag
      (while t
        (setq action
              (read-key-sequence-vector (format "size[%dx%d]"
                                                (window-width)
                                                (window-height))))
        (setq c (aref action 0))
        (cond ((= c ?l)
               (enlarge-window-horizontally dx))
              ((= c ?h)
               (shrink-window-horizontally dx))
              ((= c ?j)
               (enlarge-window dy))
              ((= c ?k)
               (shrink-window dy))
              ;; otherwise
              (t
               (let ((last-command-char (aref action 0))
                     (command (key-binding action)))
                 (when command
                   (call-interactively command)))
               (message "Quit")
               (throw 'end-flag t)))))))

;; window-resizerのキーバインド
(global-set-key "\C-c\C-r" 'window-resizer)

;;
;;=======================================================================
;; Face (emacs-goodies-el をinstallするなら不要)
;;=======================================================================
;;(custom-set-faces
;; '(default ((t
;;             (:background "black" :foreground "#00FFFF")
;;    		 )))
;; '(cursor ((((class color)
;;    		 (background dark))
;;    		(:background "#00AA00"))
;;    	   (((class color)
;;    		 (background light))
;;    		(:background "#999999"))
;;    	   (t ())
;;    	   ))
;;)
;;;; Bilt in
;;(set-face-foreground 'font-lock-builtin-face "#0080ff")
;;(set-face-bold-p 'font-lock-builtin-face t)
;;;; コメント
;;(set-face-foreground 'font-lock-comment-delimiter-face "snow4")
;;(set-face-foreground 'font-lock-comment-face "snow4")
;;;; コンスタント
;;(set-face-foreground 'font-lock-constant-face "gold")
;;;; doc (javadoc etc.)
;;(set-face-foreground 'font-lock-doc-face "#72de5d")
;;;; 関数名 タグ名など
;;(set-face-foreground 'font-lock-function-name-face "magenta")
;;;; Keyword
;;(set-face-foreground 'font-lock-keyword-face "dodger blue")
;;(set-face-bold-p 'font-lock-keyword-face t)
;;;; negation character
;;;(set-face-foreground 'font-lock-negation-char-face "red")
;;;; preprocessor
;;;(set-face-foreground 'font-lock-preprocessor-face "red")
;;;; 正規表現
;;;(set-face-foreground 'font-lock-regexp-grouping-backslash "")
;;;(set-face-foreground 'font-lock-regexp-grouping-construct "")
;;;; 文字列
;;(set-face-foreground 'font-lock-string-face "green")
;;;; Type
;;(set-face-foreground 'font-lock-type-face "light sky blue")
;;;; 変数名
;;(set-face-foreground 'font-lock-variable-name-face "yellow green")
;;;; warning?
;;;(set-face-foreground 'font-lock-warning-face "#fafafa")

;;
;;=======================================================================
;; Color Theme (emacs-goodies-el が必要)
;;=======================================================================
(require 'color-theme)
(color-theme-initialize)
(color-theme-deep-blue)
;;(color-theme-blue-mood)


;;
;;=======================================================================
;; jaspace (全角空白、タブ、改行などの表示)
;;=======================================================================
(require 'jaspace)
(setq jaspace-alternate-jaspace-string "□")
(setq jaspace-alternate-eol-string "\xab\n")
(setq jaspace-highlight-tabs t)
(setq jaspace-highlight-tabs ?^)
;; (setq jaspace-mdoes '(org-mode))

(when (and (>= emacs-major-version 23)
	   (require 'whitespace nil t))
  (setq whitespace-style
	'(face
	  tabs spaces newline trailing space-before-tab space-after-tab
	  space-mark tab-mark newline-mark))
  (let ((dark (eq 'dark (frame-parameter nil 'background-mode))))
    (set-face-attribute 'whitespace-space nil
			:foreground (if dark "pink4" "azure3")
			:background 'unspecified)
    (set-face-attribute 'whitespace-tab nil
			:foreground (if dark "gray20" "gray80")
			:background 'unspecified
			:strike-through t)
    (set-face-attribute 'whitespace-newline nil
			:foreground (if dark "dark cyan" "darkseagreen")))
  (setq whitespace-space-regexp "\\(　+\\)")
  (setq whitespace-display-mappings
	'((space-mark   ?\xA0  [?\xA4]  [?_]) ; hard space - currency
	  (space-mark   ?\x8A0 [?\x8A4] [?_]) ; hard space - currency
	  (space-mark   ?\x920 [?\x924] [?_]) ; hard space - currency
	  (space-mark   ?\xE20 [?\xE24] [?_]) ; hard space - currency
	  (space-mark   ?\xF20 [?\xF24] [?_]) ; hard space - currency
	  (space-mark   ?　    [?□]    [?＿]) ; full-width space - square
	  (newline-mark ?\n    [?\xAB ?\n])   ; eol - right quote mark
	  ))
  (setq whitespace-global-modes '(not dired-mode tar-mode))
  (global-whitespace-mode 1))


;;
;;=======================================================================
;; other
;;=======================================================================
;; emacs終了時には必ず確認する
(setq confirm-kill-emacs 'y-or-n-p)

;; *~ などのバックアップファイルを作らない
(setq make-backup-files nil)
;; 行番号表示モード
(autoload 'setnu-mode "setnu" nil t)
(global-set-key [f12] 'setnu-mode)

;; 行番号表示
(require 'linum)
(global-linum-mode)

;; undohistの設定(ファイルを閉じてもUndoできる)
;; (when (require 'undohist nil t)
;;   (undohist-initialize))

;; 全角空白とタブに色を付ける
;;(defface my-face-b-1 '((t (:background "gray"))) nil)
;;(defface my-face-b-2 '((t (:background "linen"))) nil)
;; jaspace導入により以下コメントアウト(2013.07.12)
;;(defface my-face-b-1 '((t (:background "#222222"))) nil)
;;(defface my-face-b-2 '((t (:background "#222222"))) nil)
;;(defvar my-face-b-1 'my-face-b-1)
;;(defvar my-face-b-2 'my-face-b-2)
;;(defadvice font-lock-mode (before my-font-lock-mode ())
;;  (font-lock-add-keywords
;;   major-mode
;;   '(("　" 0 my-face-b-1 append)
;;    ("\t" 0 my-face-b-2 append)
;;     )))
;;(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
;;(ad-activate 'font-lock-mode)

;; デフォルトタブをスペース4つに
(setq-default tab-width 4 indent-tabs-mode nil)

;; スクロールを1行ずつに
;;(setq scroll-step 1)
(setq scroll-conservatively 1)

;; オートインデントを無効
(setq-default c-auto-newline nil)

;; デフォルトブラウザの設定
(setq browse-url-browser-function 'browse-url-generic)
(setq browse-url-generic-program "/usr/bin/google-chrome")

;; ウィンドウ切り替え
(define-key global-map (kbd "C-t") 'other-window)

;; C-x b でミニバッファにバッファ候補を表示
(iswitchb-mode t)
;(iswitchb-default-keybindings)

;;=======================================================================
;; 専用のキーバインド、他のモードよりも優先順位が高い
;;=======================================================================
(setq my-keyjack-mode-map (make-sparse-keymap))

(mapcar (lambda (x)
          (define-key my-keyjack-mode-map (car x) (cdr x))
          (global-set-key (car x) (cdr x)))
        '(("\C-\M-h" . (lambda () (interactive) (move-to-window-line 0))) ; viのH
          ("\C-\M-m" . (lambda () (interactive) (move-to-window-line nil))) ; viのM
          ("\C-\M-l" . (lambda () (interactive) (move-to-window-line -1))) ; viのL
          ))

(easy-mmode-define-minor-mode my-keyjack-mode "Grab keys"
                              t " Keyjack" my-keyjack-mode-map)


;;
;;=======================================================================
;; Custom setting by Emacs GUI Options.
;;=======================================================================
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(cua-mode t nil (cua-base))
 '(display-time-mode t)
 '(safe-local-variable-values (quote ((encoding . utf-8))))
 '(session-use-package t nil (session))
 '(show-paren-mode t))

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#102e4e" :foreground "#eeeeee" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 113 :width normal :foundry "unknown" :family "Ricty"))))
 '(jaspace-highlight-eol-face ((t :foreground "dark slate grey"))))

;;
;;=======================================================================
;; End of File
;;=======================================================================
