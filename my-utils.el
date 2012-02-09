(require 'anything-find-project-resources)
;; プロジェクトルートディレクトリを返す
(defun my-project-root-dir ()
  "retrun project root dir of this file belongs to"
  (interactive)
  (anything-find-resource--find-project-root-dir
		  (file-name-directory (buffer-file-name))))

(defun my-project-root-dir-nointeractive ()
  (anything-find-resource--find-project-root-dir
		  (file-name-directory (buffer-file-name))))

;;; http://dev.ariel-networks.com/Members/inoue/aop-of-emacs-2
(defun thing-at-point (thing)
  (if (get thing 'thing-at-point)
      (funcall (get thing 'thing-at-point))
    (let ((bounds (bounds-of-thing-at-point thing)))
      (if bounds 
          (let ((ov (make-overlay (car bounds) (cdr bounds))))
            (overlay-put ov 'face 'region)
            (sit-for 3)
            (delete-overlay ov)
            (buffer-substring (car bounds) (cdr bounds)))))))

;;; 日付挿入
(defun my-get-datetime-gen (form) (insert (format-time-string form)))
(defun my-get-datetime () (interactive) (my-get-datetime-gen "[%Y-%m-%d %H:%M]"))

;;; リージョンの数値のみを計算する
(defun my-sum-num-region (beg end)
  "リージョン内にある数字のみを計算する"
  (interactive "r")
  (message (number-to-string
			(my-calc-list
			 '+
			 (mapcar 'string-to-number 
					 (split-string (buffer-substring beg end) "[^ 0-9 \\.]"))))))

(defun my-calc-list (ope lis)
  "リストの要素（数値）を演算する"
  (apply ope lis))

(defun my-insert-checkbox ()
  "- [ ]を入力する"
  (interactive)
  (insert "- [ ] "))

;;;
;;; php用
;;;
(defun my-beginning-of-php-defun ()
  "現在のカーソル直前のfunctionの先頭へジャンプする"
  (interactive)
  (push-mark)
  (search-backward-regexp "^[ \t]*\\(public \\|protected \\|private \\)*\\(static \\)*function")
  )

;;;
;;; python用
;;;
;; 不完全
(defun my-backward-up-python-block ()
  "現在のカーソル位置が含まれるブロックの先頭へジャンプする"
  (interactive)
  (end-of-line)
  (while (bolp) (forward-line -1)		; 空行をスキップ
		 (end-of-line))
  (let* ((indent0 (my-get-indent)))
	(search-backward ":\n")
	(while (<= indent0 (my-get-indent))
	  (search-backward ":\n"))))

(defun my-forward-python-block ()
  ""
  (interactive)
  (let* ((indent0 (my-get-indent)))
	(end-of-line)
	(search-forward ":\n")
	(forward-line -1)
	(while (< indent0 (my-get-indent))
	  (end-of-line)
	  (search-forward ":\n")
	  (forward-line -1))))

(defun my-get-indent ()
  (beginning-of-line)
  (skip-chars-forward "\t\s"))

(require 'anything-grep)
(defun href (query)
  "anything-grep-by-name for href (haskell reference)"
  (interactive "squery: ")
  (anything-grep-by-name "href" query))

(defun tweeetonly (text)
  "tweet only"
  (interactive "sWhat's up?: ")
  (shell-command (concat "python ~/bin/tweeetonly.py " "'" text "'")))

(defun blog-template (filename)
  "prepare blog template"
  (interactive "sfilename: ")
  (find-file
   (concat "~/blog/draft/suzuki-shin_"
		   (format-time-string "%Y%m%d")
		   "_" filename ".txt")))

(defun my-growl-notification (title message &optional priority sticky others)
  ""
  (shell-command
     (format
      (concat "/usr/local/bin/growlnotify -t \"%s\" -m \"%s\""
			  (if priority (concat " -p" (number-to-string priority)))
			  (if sticky " -s")
			  (if others others)
			  )
	  title message)))

(defun my-gtags-make-tags ()
  "今開いているバッファのプロジェクトのgtagsのTAGSファイルを作る"
  (interactive)
  (let ((project-dir (my-project-root-dir)))
	(shell-command (concat "cd " project-dir ";gtags&"))))

(defun get-thisweek-memo ()
  "今週の作業メモのパスを返す"
  (concat "~/memo/" (get-thisweek-monday) ".org"))

(defun get-thisweek-monday ()
  "今週の月曜日の年月日を返す"
  (let* ((weeknum (format-time-string "%w")))
		 (my-format-time-string "%Y%m%d" (+ (- (string-to-number weeknum) ) 1))))

;; simple-hatena-modeから大部分パクった
(defun my-format-time-string (format &optional dlt date)
  "format-time-stringに日時差分を渡せるようにした"
  (let ((i (if dlt dlt 0)))
			  (apply (lambda (s min h d mon y &rest rest)
					   (format-time-string format
										   (encode-time s min h (+ d i) mon y)))
					 (if date
						 (append '(0 0 0) date)
					   (apply (lambda (s min h d mon y &rest rest)
								(list s min h d mon y))
							  (decode-time))))))

;; remember the milk
(defun rtm2 ()
  "remember-the-milk-inbox"
  (interactive)
  (compose-mail mailaddress-rememberthemilk-inbox))
(defun rtm (text)
  "remember-the-milk-inbox"
  (interactive "sTo Inbox: ")
  (shell-command (concat "mail -s '" text "' -F " mailaddress-rememberthemilk-inbox)))

(defun my-task-start ()
  (interactive)
  (my-get-datetime)
  (beginning-of-line)
  (insert "*** ")
  (just-one-space))

(provide 'my-utils)
