;; Energy Distribution Contract

(define-map energy-allocations
  { civilization-id: uint }
  { allocated-energy: uint }
)

(define-data-var total-energy uint u0)

(define-public (allocate-energy (civilization-id uint) (amount uint))
  (let
    ((current-allocation (default-to u0 (get allocated-energy (map-get? energy-allocations { civilization-id: civilization-id })))))
    (asserts! (<= (+ amount (var-get total-energy)) u1000000000000) (err u401))
    (var-set total-energy (+ (var-get total-energy) amount))
    (ok (map-set energy-allocations
      { civilization-id: civilization-id }
      { allocated-energy: (+ current-allocation amount) }
    ))
  )
)

(define-public (use-energy (civilization-id uint) (amount uint))
  (let
    ((current-allocation (default-to u0 (get allocated-energy (map-get? energy-allocations { civilization-id: civilization-id })))))
    (asserts! (>= current-allocation amount) (err u401))
    (var-set total-energy (- (var-get total-energy) amount))
    (ok (map-set energy-allocations
      { civilization-id: civilization-id }
      { allocated-energy: (- current-allocation amount) }
    ))
  )
)

(define-read-only (get-energy-allocation (civilization-id uint))
  (map-get? energy-allocations { civilization-id: civilization-id })
)

(define-read-only (get-total-energy)
  (var-get total-energy)
)

