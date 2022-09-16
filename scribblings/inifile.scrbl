#lang scribble/manual

@(require
   (for-label racket
              inifile/read
              inifile/write))

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

@subsection{Reading}
@defmodule[inifile/read]

@defproc[(read-inifile [inp input-port? (current-input-port)])
         (hash/c #:immutable? #t 
                 (and/c immutable? string?) 
                 (hash/c #:immutable? #t 
                         (and/c immutable? string?) 
                         (and/c immutable? string?)))]

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

@subsection{Writing}
@defmodule[inifile/write]
@defproc[(write-inifile [inifile (hash/c string? (hash/c string? string?))]
                        [outp output-port? (current-output-port)])
         void]
