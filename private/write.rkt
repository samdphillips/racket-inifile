#lang racket/base

(require racket/generator
         racket/match)

(provide inifile-property-space
         inifile-section-newline
         write-inifile
         write-inifile-unfold)

(define inifile-section-newline (make-parameter #t))
(define inifile-property-space  (make-parameter #t))

(define (write-ini-section section-name [outp (current-output-port)])
  (when (inifile-section-newline) (newline outp))
  (fprintf outp "[~a]~%" section-name))

(define (write-ini-property key value [outp (current-output-port)])
  (fprintf outp "~a~a~a~%" key (if (inifile-property-space) " = " "=") value))

(define (write-inifile-unfold stop? mapf next value [outp (current-output-port)])
  (define (unfold value)
    (cond
      [(stop? value) (void)]
      [else
        (match (mapf value)
          [(? string? section-name)
           (write-ini-section section-name outp)]
          [(list (? string? pkey) (? string? pvalue))
           (write-ini-property pkey pvalue outp)])
        (unfold (next value))]))
  (unfold value))

(define (write-inifile a-inifile [outp (current-output-port)])
  (define gen
    (generator ()
      (for ([(section-name section) (in-hash a-inifile)])
        (yield section-name)
        (for ([(prop-name prop-value) (in-hash section)])
          (yield (list prop-name prop-value))))
      eof))
  (write-inifile-unfold eof-object?
                        values
                        (λ (v) (gen))
                        (gen)
                        outp))
