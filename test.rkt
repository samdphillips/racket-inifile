#lang racket/base

(require inifile
         (only-in inifile/private/read
                  read-ini-property)
         racket/contract
         racket/port)

(define immutable-string/c
  (flat-named-contract
    'immutable-string/c
    (and/c immutable? string?)
    (lambda (fuel)
      (define gen-string (contract-random-generate/choose string? fuel))
      (lambda ()
        (string->immutable-string  (gen-string))))))

(define (string-not-containing/c char0 . chars)
  (let ([chars (cons char0 chars)])
    (lambda (s)
      (and (string? s)
           (for*/and ([sch (in-string s)]
                      [ch  (in-list chars)])
             (not (char=? sch ch)))))))

(define strict-inifile-expr/c
  (hash/c #:immutable #t
          (and/c immutable-string/c
                 (string-not-containing/c #\return #\newline #\[ #\]))
          (hash/c #:immutable #t
                  (and/c immutable-string/c
                         (string-not-containing/c #\return #\newline #\= #\space))
                  (and/c immutable-string/c
                         (string-not-containing/c #\newline)))))

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

  (test-case "simple data round trip"
    (define test-data
      (hash "default" (hash "foo" "bar")
            "other" (hash "baz" "foo")))
    
    (define test-data-serialized
      (with-output-to-bytes
        (lambda () (write-inifile test-data))))

    (define test-data-deserialized
      (with-input-from-bytes test-data-serialized 
        (lambda () (read-inifile))))

    (check-contract strict-inifile-expr/c test-data-deserialized)
    (check-equal? test-data test-data-deserialized)))
