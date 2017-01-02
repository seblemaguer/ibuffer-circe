;;; ibuffer-circe.el --- Ibuffer integration for circe

;; Copyright (C) 2016  Sébastien Le Maguer

;; Author: Sébastien Le Maguer <slemaguer@coli.uni-saarland.de>
;; Keywords: buffer, convenience, comm
;; Package-Requires: ((cl-lib "0.2"))
;; X-URL: https://github.com/fgallina/ibuffer-circe
;; URL: https://github.com/fgallina/ibuffer-circe
;; Version: 0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Provides circe activity tracking and server filtering for ibuffer.

;;; Installation:

;; Add this to your .emacs:

;; (add-to-list 'load-path "/folder/containing/file")
;; (require 'ibuffer-circe)

;;; Usage:

;; To group buffers by irc server:

;;   M-x ibuffer-circe-set-filter-groups-by-server

;; Finally, If you want to combine the server filter groups with your
;; own, you can use `ibuffer-circe-generate-filter-groups-by-server'.

;;; Code:
(require 'cl-lib)
(require 'ibuffer)
(require 'ibuf-ext)
(require 'circe)

(defun check-irc ()
  (interactive)
  (if (eq major-mode 'circe-server-mode)
      (message (buffer-name (current-buffer)))
    (if (derived-mode-p major-mode 'circe-mode)
        (message circe-server-buffer)
      (message "not ok as not expected"))))



(defun ibuffer-circe--server-buffers ()
  "Return the list of current server buffers."
  (let ((circe-buffers
         (cl-remove-if-not
          (lambda (buffer)
            (with-current-buffer buffer
              (or (eq major-mode 'circe-server-mode)
                  (and circe-server-buffer
                       (derived-mode-p major-mode 'circe-mode)))))
          (buffer-list))))
    (cl-remove-duplicates
     (mapcar
      (lambda (buffer)
        (with-current-buffer buffer
          (if (eq major-mode 'circe-server-mode)
              buffer
            circe-server-buffer)))
      circe-buffers)
  :test #'equal)))

;;;###autoload
(defun ibuffer-circe-generate-filter-groups-by-server ()
  "Create a set of ibuffer filter groups based on the current irc servers.
Use this to programatically create your own filter groups."
  (mapcar
   (lambda (server-buffer)
     (list
      (buffer-name server-buffer)
      `(or
        (name . ,(buffer-name server-buffer))
        (predicate . (equal circe-server-buffer ,server-buffer)))))
   (ibuffer-circe--server-buffers)))

;;;###autoload
(defun ibuffer-circe-set-filter-groups-by-server ()
  "Set filter group by circe servers."
  (interactive)
  (setq ibuffer-filter-groups
        (ibuffer-circe-generate-filter-groups-by-server))
  (ibuffer-update nil t))

(provide 'ibuffer-circe)
;;; ibuffer-circe.el ends here
