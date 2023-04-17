;;; test-r-indent.el --- Tests for R indentation with tree-sitter  -*- lexical-binding: t; -*-
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; A copy of the GNU General Public License is available at
;; https://www.r-project.org/Licenses/
;;
;;; Commentary:
;;

(require 'ert)
(require 'etest "etest/etest")
(require 'ess-r-mode)
(require 'ess-test-r-utils)

(defun test-r-ts-goto (fun)
  (let ((node (test-r-ts-call-with-node fun)))
    (goto-char (cond ((numberp node)
                      node)
                     ((treesit-node-p node)
                      (r--ts-node-start node))
                     (t
                      (error "Unexpected result"))))))

(defun test-r-ts-call-with-node (fun)
  (let ((node (treesit-node-at (point))))
    (funcall (symbol-function fun)
             node
             (treesit-node-parent node))))

(etest-deftest test-r-ts-binary-root ()
  :case "
1 + 2 + ¶3
1 + 2 * 3 / ¶4
"
  (test-r-ts-goto #'r--ts-binary-root)
  :result "
¶1 + 2 + 3
¶1 + 2 * 3 / 4
"

  :case "¶1 + 2 + 3"
  (test-r-ts-goto #'r--ts-binary-root)
  :result "¶1 + 2 + 3"

  :case "
NULL
1 + ¶2 + 3"
  (test-r-ts-goto #'r--indent-binary-root-bol)
  :result "
NULL
¶1 + 2 + 3")

;; Local Variables:
;; etest-local-config: etest-r-ts-config
;; End:
