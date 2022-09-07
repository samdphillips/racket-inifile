#lang racket/base

(require inifile/private/read
         racket/port)

(module+ test
  (require rackunit)

  (test-case "read-property no spaces around key"
    (call-with-input-string "export=system"
      (λ (inp)
        (define-values (key value) (read-ini-property inp values))
        (check-equal? key "export")
        (check-equal? value "system"))))
)