;; Vacuum Energy Extraction Contract

(define-data-var next-extractor-id uint u0)

(define-map extractors
  { extractor-id: uint }
  {
    location: (tuple (x int) (y int) (z int)),
    efficiency: uint,
    energy-extracted: uint,
    status: (string-ascii 20)
  }
)

(define-public (register-extractor (x int) (y int) (z int) (efficiency uint))
  (let
    ((extractor-id (+ (var-get next-extractor-id) u1)))
    (var-set next-extractor-id extractor-id)
    (ok (map-set extractors
      { extractor-id: extractor-id }
      {
        location: { x: x, y: y, z: z },
        efficiency: efficiency,
        energy-extracted: u0,
        status: "active"
      }
    ))
  )
)

(define-public (extract-energy (extractor-id uint) (amount uint))
  (let
    ((extractor (unwrap! (map-get? extractors { extractor-id: extractor-id }) (err u404))))
    (ok (map-set extractors
      { extractor-id: extractor-id }
      (merge extractor {
        energy-extracted: (+ (get energy-extracted extractor) amount)
      })
    ))
  )
)

(define-public (update-extractor-status (extractor-id uint) (new-status (string-ascii 20)))
  (let
    ((extractor (unwrap! (map-get? extractors { extractor-id: extractor-id }) (err u404))))
    (ok (map-set extractors
      { extractor-id: extractor-id }
      (merge extractor { status: new-status })
    ))
  )
)

(define-read-only (get-extractor (extractor-id uint))
  (map-get? extractors { extractor-id: extractor-id })
)

