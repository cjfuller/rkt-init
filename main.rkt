#lang racket

(define (proc-manager [procs '()])
  (match (thread-receive)
    [(list 'add t) (proc-manager (cons t procs))]
    ['wait-all (begin
                 (for-each thread-wait procs))]))

(define pm-thread (thread proc-manager))

(define (wait-all)
  (thread-send pm-thread 'wait-all)
  (thread-wait pm-thread)
  (set! pm-thread (thread proc-manager)))

(define (init-exec fn)
  (thread-send pm-thread
               `(add ,(thread fn))))


(define (init-file f)
  (thread-send pm-thread
               `(add ,(thread (lambda ()
                                ((dynamic-require f 'init)))))))

(provide init-file wait-all)
