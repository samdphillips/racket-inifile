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

  (test-case "read-property space after key"
    (call-with-input-string "export = system"
      (λ (inp)
        (define-values (key value) (read-ini-property inp values))
        (check-equal? key "export")
        (check-equal? value "system"))))

  (test-case "read-inifile with empty file"
    (define value (call-with-input-string "" read-inifile))
    (check-equal? value (hash)))
)