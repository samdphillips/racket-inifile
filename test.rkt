#lang racket/base

(require inifile
         (only-in inifile/private/read
                  read-ini-property)
         racket/contract
         racket/port)

(define strict-inifile-expr/c
  (hash/c #:immutable #t
          (and/c immutable? string?)
          (hash/c #:immutable #t
                  (and/c immutable? string?)
                  (and/c immutable? string?))))

(module+ test
  (require rackunit)

  (define-check (check-contract ctc value)
    (with-check-info (['contract (contract-name ctc)]
                      ['params   (list value)])
      (unless (ctc value)
        (fail-check "contract failed"))))

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
    (check-contract strict-inifile-expr/c value)
    (check-equal? value (hash)))

  (test-case "read-inifile with simple data"
    (define test-data #<<INI
[default]
foo = bar

[other]
baz = foo
INI
    )
    (define value (call-with-input-string test-data read-inifile))
    (check-contract strict-inifile-expr/c value)
    (check-equal? value
                  (hash "default" (hash "foo" "bar")
                        "other"   (hash "baz" "foo"))))
)