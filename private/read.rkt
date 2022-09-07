#lang racket/base

(require racket/match)

(provide read-inifile
         read-ini-line
         read-ini-property)

(define (skip-spaces! inp)
  (define ch (peek-char inp))
  (unless (eof-object? ch)
    (when (or (char-whitespace? ch) (char=? #\# ch))
      (match ch
        [(? char-whitespace?) (read-char inp)]
        [#\# (read-line inp)])
      (skip-spaces! inp))))

(define (read-ini-section inp handler)
  (match (read-line inp)
    [(regexp #px"\\[(.*)\\]\\s*" (list _ name)) (handler name)]
    [line (error 'read-ini-section
                 "expected section got: ~s" line)]))

(define (read-ini-property inp handler)
  (match (read-line inp)
    ;; XXX handle line continuations
    [(regexp #px"([^=\\s]+)\\s*=\\s*(.*)" (list _ key value)) (handler key value)]
    [line (error 'read-ini-property
                 "expected property got: ~s" line)]))

(define (read-ini-line [inp         (current-input-port)]
                       [on-section  values]
                       [on-property values]
                       [on-eof      (lambda () eof)])
  (skip-spaces! inp)
  (match (peek-char inp)
    [(? eof-object?) (on-eof)]
    [#\[             (read-ini-section inp on-section)]
    [_               (read-ini-property inp on-property)]))

(define (read-inifile-fold inp seed on-section on-property on-eof)
  (define (once state)
    (define (k-section name)
      (once (on-section state name)))
    (define (k-property key value)
      (once (on-property state key value)))
    (define (k-eof)
      (on-eof state))
    (read-ini-line inp k-section k-property k-eof))
  (once seed))

(struct inifile-hash-builder (current-section current-properties table))

(define (read-inifile [inp (current-input-port)])
  (define (on-section b section-name)
    (match b
      [(inifile-hash-builder #f _ tbl)
       (inifile-hash-builder section-name (hash) tbl)]
      [(inifile-hash-builder old props tbl)
       (inifile-hash-builder section-name (hash)
                             (hash-set tbl old props))]))
  (define (on-property b key value)
    (match b
      [(inifile-hash-builder section props tbl)
       (inifile-hash-builder section (hash-set props key value) tbl)]))
  (define (on-eof b)
    (inifile-hash-builder-table (on-section b #f)))
  (define init-b (inifile-hash-builder #f (hash) (hash)))
  (read-inifile-fold inp init-b on-section on-property on-eof))