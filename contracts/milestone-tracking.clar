;; Milestone Tracking Contract
;; Monitors project progress and releases funds

(define-map milestones
  { id: uint }
  {
    project-id: uint,
    title: (string-ascii 50),
    funds-needed: uint,
    status: (string-ascii 10)
  }
)

(define-map project-progress
  { project-id: uint }
  {
    current-milestone: uint,
    funds-released: uint
  }
)

(define-data-var last-id uint u0)

;; Create a new milestone
(define-public (create-milestone
              (project-id uint)
              (title (string-ascii 50))
              (funds-needed uint))
  (let
    (
      (new-id (+ (var-get last-id) u1))
      (project-data (default-to
                    { current-milestone: u0, funds-released: u0 }
                    (map-get? project-progress { project-id: project-id })))
    )
    ;; Validate inputs
    (asserts! (> funds-needed u0) (err u1))

    ;; Update milestone counter
    (var-set last-id new-id)

    ;; Create the milestone
    (ok (map-set milestones
      { id: new-id }
      {
        project-id: project-id,
        title: title,
        funds-needed: funds-needed,
        status: "pending"
      }
    ))
  )
)

;; Complete milestone and release funds
(define-public (complete-milestone (milestone-id uint))
  (let
    (
      (milestone (unwrap! (get-milestone milestone-id) (err u404)))
      (project-data (unwrap! (get-project-progress (get project-id milestone)) (err u405)))
    )
    ;; Update milestone status
    (map-set milestones
      { id: milestone-id }
      (merge milestone { status: "completed" })
    )

    ;; Update project progress
    (ok (map-set project-progress
      { project-id: (get project-id milestone) }
      {
        current-milestone: (+ (get current-milestone project-data) u1),
        funds-released: (+ (get funds-released project-data) (get funds-needed milestone))
      }
    ))
  )
)

;; Get milestone details
(define-read-only (get-milestone (id uint))
  (map-get? milestones { id: id })
)

;; Get project progress
(define-read-only (get-project-progress (project-id uint))
  (map-get? project-progress { project-id: project-id })
)
