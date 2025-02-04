;; Main DEX Contract

(define-map orders
  { order-id: uint }
  {
    trader: principal,
    token-x: (string-ascii 32),
    token-y: (string-ascii 32),
    amount-x: uint,
    amount-y: uint,
    order-type: (string-ascii 4)
  }
)

(define-data-var order-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_ORDER (err u400))

(define-read-only (get-order (order-id uint))
  (map-get? orders { order-id: order-id })
)

(define-public (create-order
    (token-x (string-ascii 32))
    (token-y (string-ascii 32))
    (amount-x uint)
    (amount-y uint)
    (order-type (string-ascii 4)))
  (let
    ((new-order-id (+ (var-get order-nonce) u1)))
    (asserts! (or (is-eq order-type "buy") (is-eq order-type "sell")) ERR_INVALID_ORDER)
    (map-set orders
      { order-id: new-order-id }
      {
        trader: tx-sender,
        token-x: token-x,
        token-y: token-y,
        amount-x: amount-x,
        amount-y: amount-y,
        order-type: order-type
      }
    )
    (var-set order-nonce new-order-id)
    (ok new-order-id)
  )
)

(define-public (cancel-order (order-id uint))
  (let
    ((order (unwrap! (get-order order-id) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get trader order)) ERR_UNAUTHORIZED)
    (map-delete orders { order-id: order-id })
    (ok true)
  )
)

(define-read-only (get-all-orders)
  (ok (var-get order-nonce))
)

