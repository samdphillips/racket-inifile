#lang racket/base

(require inifile/private/read
         racket/contract)

(provide (contract-out
           [read-ini-line (->* ()
                               (input-port?
                                (-> string? any)
                                (-> string? string? any)
                                (-> any))
                               any)]
           [read-inifile (->* () (input-port?) hash?)]
                               ))

; XXX make an inifile writer

