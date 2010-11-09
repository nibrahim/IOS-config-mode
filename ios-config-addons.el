;;; ios-config-addons.el
;; Copyright (C) 2004 Noufal Ibrahim <nkv at nibrahim.net.in>
;;
;; This program is not part of Gnu Emacs
;;
;; ios-config-addons.el is free software and a part of
;; ios-config-mode.el; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the
;; Free Software Foundation; either version 2 of the License, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

(defun ioscfg-add-command-to-interfaces (command &optional intf)
  "Add COMMAND (if it's not already there) to interfaces that match regexp INTF. If INTF is null, work on all interfaces.
   This requires the buffer to be indented properly."
  (interactive "MCommand: \nMInterface: ") 
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (while (progn
	       (if (looking-at (concat "^[Ii]nterface " intf))
		   (let ((block-end (ioscfg-find-interface-block (point))))
		     (if (not (ioscfg-command-in-block-p command block-end))
			 (save-excursion
			   (goto-char (+ block-end 1))
			   (insert " " command "\n")))))
	       (not (= (forward-line) 1)))))))
	

(defun ioscfg-find-interface-block (pt)
  (save-excursion 
    (goto-char pt)
    (forward-line)
    (while (looking-at "^ .*")
      (forward-line 1))
    (- (point) 1)))
      
(defun ioscfg-command-in-block-p (cmd end)
  (save-excursion
    (search-forward-regexp cmd end t)))
  
(defun ioscfg-unshut-all-interfaces ()
  "Removes the \"shutdown\" or \"shut\" command from all interfaces and adds a \"no shutdown\" instead."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^\\([ \t]*shut\\(down\\)?\\)$" nil t)
      (beginning-of-line)
      (kill-line 1)))
  (ioscfg-add-command-to-interfaces "no shutdown"))

(defun ioscfg-shut-all-interfaces ()
  "Removes the \"no shutdown\" or \"no shut\" command from all interfaces and adds a \"shutdown\" instead."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^\\([ \t]*no shut\\(down\\)?\\)$" nil t)
      (beginning-of-line)
      (kill-line 1)))
  (ioscfg-add-command-to-interfaces "shutdown"))
				      
(provide 'ios-config-addons)

;;; ios-config-addons.el ends here
