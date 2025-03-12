;; Refund Contract
;; Manages return of funds if project goals are not met

(define-map refunds
  { id: uint }
  {
    pledge-id: uint,
    project-id: uint,
    backer: principal,
    amount: uint,
    status: (string-ascii 10)
  }
)

(define-map project-refunds
  { project-id: uint }
  {
    total-refunded: uint,
    refund-count: uint
  }
)

(define-data-var last-id uint u0)

;; Request a refund
(define-public (request-refund (pledge-id uint) (project-id uint) (amount uint))
  (let
    (
      (new-id (+ (var-get last-id) u1))
      (project-data (default-to
                    { total-refunded: u0, refund-count: u0 }
                    (map-get? project-refunds { project-id: project-id })))
    )
    ;; Validate inputs
    (asserts! (> amount u0) (err u1))

    ;; Update refund counter
    (var-set last-id new-id)

    ;; Update project refunds
    (map-set project-refunds
      { project-id: project-id }
      {
        total-refunded: (+ (get total-refunded project-data) amount),
        refund-count: (+ (get refund-count project-data) u1)
      }
    )

    ;; Create the refund
    (ok (map-set refunds
      { id: new-id }
      {
        pledge-id: pledge-id,
        project-id: project-id,
        backer: tx-sender,
        amount: amount,
        status: "pending"
      }
    ))
  )
)

;; Process a refund
(define-public (process-refund (refund-id uint))
  (let
    (
      (refund (unwrap! (get-refund refund-id) (err u404)))
    )
    ;; Update refund status
    (ok (map-set refunds
      { id: refund-id }
      (merge refund { status: "processed" })
    ))
  )
)

;; Get refund details
(define-read-only (get-refund (id uint))
  (map-get? refunds { id: id })
)

;; Get project refund totals
(define-read-only (get-project-refund-totals (project-id uint))
  (map-get? project-refunds { project-id: project-id })
)
