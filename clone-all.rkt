#lang racket/base

(require pkg pkg/lib setup/setup)

(define default '("~a" "~a-lib" "~a-doc"))

(define all-pkgs
  (hash "distro-build" '("~a" "~a-lib" "~a-client" "~a-server")
        "remote-shell" default
        "plt-web" default
        "racket-lang-org" #f
        "pkg-build" #f
        "pkg-push" #f
        "games" #f
        "drdr" #f
        "make" #f
        "eopl" #f
        "preprocessor" #f
        "swindle" #f
        "picturing-programs" #f
        "slatex" #f))

(define (gen-all-pkgs p sub)
  (if sub
      (for/list ([fmt sub])
        (format fmt p))
      (list p)))

(module+ main
  (require racket/cmdline)
  (define setup-at-end #f)
  (define setup? #t)
  (define run? #f)

  (command-line
   #:program "clone-all"
   #:once-any
   [("--setup-at-end") "Run `raco setup' once at the end" (set! setup-at-end #t)]
   [("--no-setup") "Don't run `raco setup' at all" (set! setup? #f)]
  #:args 
  ([dir (current-directory)])

  (for ([(p* sub) all-pkgs])
    (define ps (gen-all-pkgs p* sub))
    (define p (build-path dir p*))
    (unless (or (directory-exists? p)
                (ormap pkg-directory ps))
      (set! run? #t)
      (apply pkg-install-command #:no-setup (if setup? setup-at-end #t)  #:clone p ps)))
  (when (and run? setup? setup-at-end)
    (setup))))
  
