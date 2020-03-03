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
    (((type tty) (class color)) (:foreground "yellow"))
    (((type graphic) (class color)) (:foreground "LightGoldenrod"))
    (t (:foreground "LightGoldenrod" ))
    )
  "Face for IP addresses")

(defface ios-config-command-face 
  '(
    (((type tty) (class color)) (:foreground "cyan"))
    (((type graphic) (class color)) (:foreground "cyan"))
    (t (:foreground "cyan" ))
    )
  "Face for basic router commands")

(defface ios-config-toplevel-face
  '(
    (((type tty) (class color)) (:foreground "blue"))
    (((type graphic) (class color)) (:foreground "lightsteelblue"))
    (t (:foreground "lightsteelblue" ))
    )
  "Face for basic router commands")

(defface ios-config-no-face
  '(
    (t (:underline t))
    )
  "Face for \"no\"")

(defconst ios-config-font-lock-keywords
  `((,(concat "\\_<"
       (regexp-opt '("access-list" "class-map" "controller" "interface" "vrf"
                     "line" "policy-map" "redundancy-map" "route-map"
                     "object-group" "access-group" "cluster" "username"
                     "service-policy") t)
       "\\_>")
     . ios-config-toplevel-face)
    (,(concat "\\_<"
       (regexp-opt '("alias" "boot" "card" "diagnostic" "enable" "hostname"
                     "logging" "service" "snmp-server" "version" "vtp" "names"
                     "description" "lacp" "port-channel" "mac-address" "vlan"
                     "nameif" "security-level" "ip" "ospf" "ftp"
                     "network-object" "service-object" "icmp-object"
                     "protocol-object" "group-object" "host" "network" "mtu"
                     "icmp" "asdm" "prefix-list" "timeout" "user-identity" "aaa"
                     "http" "crypto" "telnet" "ssh" "console" "threat-detection"
                     "ssl" "service-type" "match" "class" "parameters" "inspect"
                     "prompt" "jumbo-frame" "shutdown" "address"
                     "management-only" "destination" "extended" "permit" "any"
                     "type" "for" "priority" "health-check" "failover"
                     "monitor-interface" "arp" "area" "server" "scopy"
                     "message-length" "call-home" "password" "encrypted"
                     "privilege") t)
       "\\_>")
     . ios-config-command-face)
    ("\\<\\(no\\)\\>" . ios-config-no-face)
    ("\\<\\([0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\)\\>" . ios-config-ipadd-face))

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
