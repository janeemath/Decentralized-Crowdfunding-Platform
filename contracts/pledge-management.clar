;; Pledge Management Contract
;; Handles investor contributions

(define-map pledges
  { id: uint }
  {
    project-id: uint,
    backer: principal,
    amount: uint,
    status: (string-ascii 10)
  }
)

(define-map project-totals
  { project-id: uint }
  {
    total-pledged: uint,
    backer-count: uint
  }
)

(define-data-var last-id uint u0)

;; Make a pledge to a project
(define-public (make-pledge (project-id uint) (amount uint))
  (let
    (
      (new-id (+ (var-get last-id) u1))
      (project-data (default-to
                    { total-pledged: u0, backer-count: u0 }
                    (map-get? project-totals { project-id: project-id })))
    )
    ;; Validate inputs
    (asserts! (> amount u0) (err u1))

    ;; Update pledge counter
    (var-set last-id new-id)

    ;; Update project totals
    (map-set project-totals
      { project-id: project-id }
      {
        total-pledged: (+ (get total-pledged project-data) amount),
        backer-count: (+ (get backer-count project-data) u1)
      }
    )

    ;; Create the pledge
    (ok (map-set pledges
      { id: new-id }
      {
        project-id: project-id,
        backer: tx-sender,
        amount: amount,
        status: "active"
      }
    ))
  )
)

;; Cancel a pledge
(define-public (cancel-pledge (pledge-id uint))
  (let
    (
      (pledge (unwrap! (get-pledge pledge-id) (err u404)))
    )
    ;; Only backer can cancel
    (asserts! (is-eq tx-sender (get backer pledge)) (err u403))

    (ok (map-set pledges
      { id: pledge-id }
      (merge pledge { status: "cancelled" })
    ))
  )
)

;; Get pledge details
(define-read-only (get-pledge (id uint))
  (map-get? pledges { id: id })
)

;; Get project totals
(define-read-only (get-project-totals (project-id uint))
  (map-get? project-totals { project-id: project-id })
)
