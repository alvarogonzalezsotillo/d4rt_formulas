;;; d4rt-formulas-imenu.el --- Imenu index for d4rt formulas and units files  -*- lexical-binding: t; -*-

;; Keywords: convenience, tools
;; Version: 0.1

;;; Commentary:

;; The d4rt_formulas application stores its formulas and units as dart
;; literals in text assets:
;;
;;   * *.d4rt.formulas -- an array of formula objects.  Each object has
;;     a "name" string and "input", "output" and "tags" keys.
;;   * *.d4rt.units    -- an array of single-line unit objects.
;;
;; This library builds an imenu index for those files:
;;
;;   * In a formulas file, the first level of the index is the "name"
;;     property and the second level is made of the "input", "output"
;;     and "tags" keys.
;;   * In a units file, the index is a flat list of unit "name"s.
;;
;; The asset files themselves carry a file-local variables block that
;; enables `dart-mode' and `d4rt-formulas-imenu-mode' automatically:
;;
;;   // Local Variables:
;;   // mode: dart
;;   // d4rt-formulas-imenu-mode: t
;;   // End:
;;
;; The mode variable is marked safe (see below), so opening an asset
;; file applies it without prompting.  Alternative ways to enable it:
;;
;;   (add-hook 'dart-mode-hook #'d4rt-formulas-imenu-enable)
;;
;; or toggle it manually in a buffer:
;;
;;   M-x d4rt-formulas-imenu-mode

;;; Code:

(defconst d4rt-formulas-imenu--name-re
  "^[ \t]*\"name\"[ \t]*:[ \t]*\"\\([^\"]*\\)\""
  "Regexp matching the \"name\" key of a formula object.

Group 1 is the name value.  Lines of the form `{\"name\": ...}' (the
variables inside an \"input\" array) are not matched because they
start with a brace.")

(defconst d4rt-formulas-imenu--unit-name-re
  "^[ \t]*{?[ \t]*\"name\"[ \t]*:[ \t]*\"\\([^\"]*\\)\""
  "Regexp matching the \"name\" key of a unit object.

Group 1 is the name value.  Unit objects are single-line literals that
start with a brace, unlike formula objects whose keys are on their own
lines.")

(defconst d4rt-formulas-imenu--key-re
  "^[ \t]*\"%s\""
  "Format string matching the line of a top-level formula key.")

(defun d4rt-formulas-imenu--formula-entry (name start end)
  "Return an imenu entry for the formula named NAME.

START is the position of the formula \"name\" key and END the position
of the next formula \"name\" key (or `point-max').  The children of the
entry are the \"input\", \"output\" and \"tags\" keys."
  (let (children)
    (save-excursion
      (dolist (key '("name" "input" "output" "tags"))
        (goto-char start)
        (when (re-search-forward (format d4rt-formulas-imenu--key-re key) end t)
          (push (cons key (match-beginning 0)) children))))
    (cons name (nreverse children))
    ))

(defun d4rt-formulas-imenu--formula-index ()
  "Return the imenu index of a d4rt formulas buffer.

The index is a list of two-level entries: each formula name maps to a
list holding the \"input\", \"output\" and \"tags\" key positions."
  (let (entries)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward d4rt-formulas-imenu--name-re nil t)
        (let* ((start (match-beginning 0))
               (name (match-string-no-properties 1))
               (end (save-excursion
                      (if (re-search-forward d4rt-formulas-imenu--name-re nil t)
                          (match-beginning 0)
                        (point-max)))))
          (push (d4rt-formulas-imenu--formula-entry name start end) entries))))
    (nreverse entries)))

(defun d4rt-formulas-imenu--unit-index ()
  "Return the imenu index of a d4rt units buffer.

The index is a flat list of unit name entries in file order."
  (let (entries)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward d4rt-formulas-imenu--unit-name-re nil t)
        (push (cons (match-string-no-properties 1) (match-beginning 0)) entries)))
    (nreverse entries)))

(defun d4rt-formulas-imenu-create-index ()
  "Create the imenu index for the current buffer.

Formula files (*.d4rt.formulas) get a two-level index (name ->
input/output/tags); unit files (*.d4rt.units) get a flat index of
unit names."
  (save-excursion
    (save-restriction
      (widen)
      (if (string-match-p "\\.d4rt\\.units\\'" (or (buffer-file-name) ""))
          (d4rt-formulas-imenu--unit-index)
        (d4rt-formulas-imenu--formula-index)))))

;;;###autoload
(define-minor-mode d4rt-formulas-imenu-mode
  "Build an imenu index for d4rt formulas and units files.

When enabled, `imenu-create-index-function' is set to
`d4rt-formulas-imenu-create-index' for the current buffer."
  :lighter " d4rt-imenu"
  :group 'imenu
  (if d4rt-formulas-imenu-mode
      (setq-local imenu-create-index-function #'d4rt-formulas-imenu-create-index)
    (kill-local-variable 'imenu-create-index-function)))

;; A boolean value for the mode variable is safe to set from a
;; file-local variables block, so opening an asset file applies it
;; without prompting.
(put 'd4rt-formulas-imenu-mode 'safe-local-variable 'booleanp)

;;;###autoload
(defun d4rt-formulas-imenu-enable ()
  (interactive)
  "Enable `d4rt-formulas-imenu-mode' if the current file is a d4rt asset.

Meant to be added to `dart-mode-hook'."
  (add-hook 'dart-mode-hook #'d4rt-formulas-imenu-enable)
  (when (string-match-p "\\.d4rt\\.\\(formulas\\|units\\)\\'" (or (buffer-file-name) ""))
    (d4rt-formulas-imenu-mode 1)))

(provide 'd4rt-formulas-imenu)

;;; d4rt-formulas-imenu.el ends here
