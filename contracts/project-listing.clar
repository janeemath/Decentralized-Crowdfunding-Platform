;; Project Listing Contract
;; Manages campaign details and funding goals

(define-map projects
  { id: uint }
  {
    creator: principal,
    title: (string-ascii 50),
    description: (string-ascii 200),
    goal: uint,
    deadline: uint,
    status: (string-ascii 10)
  }
)

(define-data-var last-id uint u0)

;; Create a new project
(define-public (create-project
              (title (string-ascii 50))
              (description (string-ascii 200))
              (goal uint)
              (deadline uint))
  (let
    (
      (new-id (+ (var-get last-id) u1))
    )
    ;; Validate inputs
    (asserts! (> goal u0) (err u1))
    (asserts! (> deadline block-height) (err u2))

    ;; Update project counter
    (var-set last-id new-id)

    ;; Create the project
    (ok (map-set projects
      { id: new-id }
      {
        creator: tx-sender,
        title: title,
        description: description,
        goal: goal,
        deadline: deadline,
        status: "active"
      }
    ))
  )
)

;; Update project status
(define-public (update-status (project-id uint) (status (string-ascii 10)))
  (let
    (
      (project (unwrap! (get-project project-id) (err u404)))
    )
    ;; Only creator can update status
    (asserts! (is-eq tx-sender (get creator project)) (err u403))

    (ok (map-set projects
      { id: project-id }
      (merge project { status: status })
    ))
  )
)

;; Get project details
(define-read-only (get-project (id uint))
  (map-get? projects { id: id })
)

;; Get total projects count
(define-read-only (get-total-projects)
  (var-get last-id)
)
