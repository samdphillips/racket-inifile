#lang racket/base

(require inifile/private/write
         racket/contract)

(provide (contract-out
           [write-inifile (->* ((hash/c string? (hash/c string? string?)))
                               (output-port?) any)]))
