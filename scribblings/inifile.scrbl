#lang scribble/manual

@(require
   (for-label racket
              inifile))

@title{inifile: a library for reading and writing inifiles}
@author[(author+email "Sam Phillips" "samdphillips@gmail.com")]

@(when (equal? ".github/workflows/docs.yml" (getenv "GITHUB_WORKFLOW"))
   @para{@bold{WARNING!}  This documentation is for the development version of
         @racket[inifile].  Release documentation is at
         @(let ([x "https://docs.racket-lang.org/inifile/index.html"])
            (link x x)).})

The @racket[inifile] library is a library to access inifiles.

@section{Reference}
@defmodule[inifile]

@defproc[(read-inifile [inp input-port? (current-input-port)])
         (hash/c string? (hash/c string? string?))]

@defproc[(read-ini-line [inp         input-port?              (current-input-port)]
                        [on-section  (-> string? any)         values]
                        [on-property (-> string? string? any) values]
                        [on-eof      (-> any)                 (λ () eof)])
         any]

@defproc[(read-inifile-fold [inp         input-port?]
                            [seed        any/c]
                            [on-section  (-> any/c string? any)]
                            [on-property (-> any/c string? string? any)]
                            [on-eof      (-> any/c any)])
         any]