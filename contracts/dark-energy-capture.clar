;; Dark Energy Capture Contract

(define-data-var next-collector-id uint u0)

(define-map collectors
  { collector-id: uint }
  {
    location: (tuple (x int) (y int) (z int)),
    capacity: uint,
    energy-collected: uint,
    status: (string-ascii 20)
  }
)

(define-public (register-collector (x int) (y int) (z int) (capacity uint))
  (let
    ((collector-id (+ (var-get next-collector-id) u1)))
    (var-set next-collector-id collector-id)
    (ok (map-set collectors
      { collector-id: collector-id }
      {
        location: { x: x, y: y, z: z },
        capacity: capacity,
        energy-collected: u0,
        status: "active"
      }
    ))
  )
)

(define-public (collect-energy (collector-id uint) (amount uint))
  (let
    ((collector (unwrap! (map-get? collectors { collector-id: collector-id }) (err u404))))
    (asserts! (<= (+ (get energy-collected collector) amount) (get capacity collector)) (err u401))
    (ok (map-set collectors
      { collector-id: collector-id }
      (merge collector {
        energy-collected: (+ (get energy-collected collector) amount)
      })
    ))
  )
)

(define-public (update-collector-status (collector-id uint) (new-status (string-ascii 20)))
  (let
    ((collector (unwrap! (map-get? collectors { collector-id: collector-id }) (err u404))))
    (ok (map-set collectors
      { collector-id: collector-id }
      (merge collector { status: new-status })
    ))
  )
)

(define-read-only (get-collector (collector-id uint))
  (map-get? collectors { collector-id: collector-id })
)

