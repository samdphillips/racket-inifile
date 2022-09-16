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
           [read-inifile-fold (-> input-port?
                                  any/c
                                  (-> any/c string? any)
                                  (-> any/c string? string? any)
                                  (-> any/c any)
                                  any)]
           [read-inifile (->* () (input-port?) hash?)]))