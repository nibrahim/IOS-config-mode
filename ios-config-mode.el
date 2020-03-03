;;; ios-config-mode.el --- edit Cisco IOS configuration files

;; Copyright (C) 2004 Noufal Ibrahim <nkv at nibrahim.net.in>
;;
;; This program is not part of Gnu Emacs
;;
;; ios-config-mode.el is free software; you can
;; redistribute it and/or modify it under the terms of the GNU General
;; Public License as published by the Free Software Foundation; either
;; version 2 of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

;;; Code:

(defvar ios-config-mode-hook nil
  "Hook called by \"ios-config-mode\"")

(defvar ios-config-mode-map
  (let 
      ((ios-config-mode-map (make-keymap)))
    (define-key ios-config-mode-map "\C-j" 'newline-and-indent)
    ios-config-mode-map)
  "Keymap for Cisco router configuration major mode")

;; Font locking definitions. 
(defvar ios-config-command-face 'ios-config-command-face "Face for basic router commands")
(defvar ios-config-toplevel-face 'ios-config-toplevel-face "Face for top level commands")
(defvar ios-config-no-face 'ios-config-no-face "Face for \"no\"")
(defvar ios-config-ipadd-face 'ios-config-ipadd-face "Face for IP addresses")

(defface ios-config-ipadd-face
  '(
    (t (:inherit font-lock-type-face))
    )
  "Face for IP addresses")

(defface ios-config-command-face 
  '(
    (t (:inherit font-lock-builtin-face))
    )
  "Face for basic router commands")

(defface ios-config-toplevel-face
  '(
    (t (:inherit font-lock-keyword-face))
    )
  "Face for basic router commands")

(defface ios-config-no-face
  '(
    (t (:underline t))
    )
  "Face for \"no\"")


;; (regexp-opt '("interface" "ip vrf" "controller" "class-map" "redundancy" "line" "policy-map" "router" "access-list" "route-map") t)
;; (regexp-opt '("diagnostic" "hostname" "logging" "service" "alias" "snmp-server" "boot" "card" "vtp" "version" "enable") t)

(defconst ios-config-font-lock-keywords
  (list
   '( "\\<\\(access-list\\|c\\(?:lass-map\\|ontroller\\)\\|i\\(?:nterface\\|p vrf\\)\\|line\\|policy-map\\|r\\(?:edundancy\\|oute\\(?:-map\\|r\\)\\)\\)\\>". ios-config-toplevel-face)
   '( "\\<\\(alias\\|boot\\|card\\|diagnostic\\|^enable\\|hostname\\|logging\\|s\\(?:ervice\\|nmp-server\\)\\|v\\(?:ersion\\|tp\\)\\)\\>" . ios-config-command-face)
   '("\\<\\(no\\)\\>" . ios-config-no-face)
   '("\\<\\([0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\)\\>" . ios-config-ipadd-face)
   )
  "Font locking definitions for cisco router mode")

;; Imenu definitions. 
(defvar ios-config-imenu-expression
  '(
    ("Interfaces"        "^[\t ]*interface *\\(.*\\)" 1)
    ("VRFs"              "^ip vrf *\\(.*\\)" 1)
    ("Controllers"       "^[\t ]*controller *\\(.*\\)" 1)
    ("Routing protocols" "^router *\\(.*\\)" 1)
    ("Class maps"        "^class-map *\\(.*\\)" 1)
    ("Policy maps"       "^policy-map *\\(.*\\)" 1)
    ))
  
;; Indentation definitions.
(defun ios-config-indent-line ()
  "Indent current line as cisco router config line"
  (let ((indent0 "^interface\\|redundancy\\|^line\\|^ip vrf \\|^controller\\|^class-map\\|^policy-map\\|router\\|access-list\\|route-map")
	(indent1 " *main-cpu\\| *class\\W"))
    (beginning-of-line)
    (let ((not-indented t)
	  (cur-indent 0))
      (cond ((or (bobp) (looking-at indent0) (looking-at "!")) ; Handles the indent0 and indent1 lines
	     (setq not-indented nil
		   cur-indent 0))
	    ((looking-at indent1)
	     (setq not-indented nil
		   cur-indent 1)))
      (save-excursion ; Indents regular lines depending on the block they're in.
	(while not-indented
	  (forward-line -1)
	  (cond ((looking-at indent1)
		 (setq cur-indent 2
		       not-indented nil))
		((looking-at indent0)
		 (setq cur-indent 1
		       not-indented nil))
		((looking-at "!")
		 (setq cur-indent 0
		       not-indented nil))
		((bobp) 
		 (setq cur-indent 0
		       not-indented nil)))))
      (indent-line-to cur-indent))))


;; Custom syntax table
(defvar ios-config-mode-syntax-table (make-syntax-table) 
  "Syntax table for cisco router mode")

(modify-syntax-entry ?_ "w" ios-config-mode-syntax-table) ;All _'s are part of words. 
(modify-syntax-entry ?- "w" ios-config-mode-syntax-table) ;All -'s are part of words. 
(modify-syntax-entry ?! "<" ios-config-mode-syntax-table) ;All !'s start comments. 
(modify-syntax-entry ?\n ">" ios-config-mode-syntax-table) ;All newlines end comments.
(modify-syntax-entry ?\r ">" ios-config-mode-syntax-table) ;All linefeeds end comments.

;; Entry point
(defun ios-config-mode  ()
  "Major mode for editing Cisco IOS (tm) configuration files"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table ios-config-mode-syntax-table)
  (use-local-map ios-config-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(ios-config-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'ios-config-indent-line)
  (set (make-local-variable 'comment-start) "!")
  (set (make-local-variable 'comment-start-skip) "\\(\\(^\\|[^\\\\\n]\\)\\(\\\\\\\\\\)*\\)!+ *")
  (setq imenu-case-fold-search nil)  
  (set (make-local-variable 'imenu-generic-expression) ios-config-imenu-expression)
  (imenu-add-to-menubar "Imenu")
  (setq major-mode 'ios-config-mode
	mode-name "IOS configuration")
  (run-hooks ios-config-mode-hook))

(add-to-list 'auto-mode-alist '("\\.cfg\\'" . ios-config-mode))

(provide 'ios-config-mode)

;;; ios-config-mode.el ends here
