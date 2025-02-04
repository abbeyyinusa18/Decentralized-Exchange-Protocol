;; Fee Distribution Contract

(define-map fee-balances
  { user: principal }
  { balance: uint }
)

(define-data-var total-fees uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_INSUFFICIENT_BALANCE (err u401))

(define-read-only (get-fee-balance (user principal))
  (default-to { balance: u0 } (map-get? fee-balances { user: user }))
)

(define-public (add-fees (amount uint))
  (begin
    (var-set total-fees (+ (var-get total-fees) amount))
    (ok true)
  )
)

(define-public (distribute-fees (recipients (list 200 { user: principal, share: uint })))
  (let
    ((total-shares (fold + (map get-share recipients) u0)))
    (map distribute-to-recipient recipients)
    (ok true)
  )
)

(define-private (distribute-to-recipient (recipient { user: principal, share: uint }))
  (let
    ((amount (/ (* (var-get total-fees) (get share recipient)) u100)))
    (map-set fee-balances
      { user: (get user recipient) }
      { balance: (+ (get balance (get-fee-balance (get user recipient))) amount) }
    )
  )
)

(define-public (withdraw-fees (amount uint))
  (let
    ((balance (get balance (get-fee-balance tx-sender))))
    (asserts! (<= amount balance) ERR_INSUFFICIENT_BALANCE)
    (map-set fee-balances
      { user: tx-sender }
      { balance: (- balance amount) }
    )
    (ok true)
  )
)

(define-read-only (get-total-fees)
  (ok (var-get total-fees))
)

(define-private (get-share (recipient { user: principal, share: uint }))
  (get share recipient)
)

