;; Governance Contract

(define-map proposals
  { proposal-id: uint }
  {
    proposer: principal,
    description: (string-utf8 500),
    votes-for: uint,
    votes-against: uint,
    status: (string-ascii 10),
    end-block: uint
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { amount: uint, vote: bool }
)

(define-data-var proposal-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_VOTED (err u409))
(define-constant ERR_PROPOSAL_ENDED (err u410))

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals { proposal-id: proposal-id })
)

(define-public (create-proposal (description (string-utf8 500)) (duration uint))
  (let
    ((new-proposal-id (+ (var-get proposal-nonce) u1)))
    (map-set proposals
      { proposal-id: new-proposal-id }
      {
        proposer: tx-sender,
        description: description,
        votes-for: u0,
        votes-against: u0,
        status: "active",
        end-block: (+ block-height duration)
      }
    )
    (var-set proposal-nonce new-proposal-id)
    (ok new-proposal-id)
  )
)

(define-public (vote (proposal-id uint) (amount uint) (vote-for bool))
  (let
    ((proposal (unwrap! (get-proposal proposal-id) ERR_NOT_FOUND)))
    (asserts! (< block-height (get end-block proposal)) ERR_PROPOSAL_ENDED)
    (asserts! (is-none (map-get? votes { proposal-id: proposal-id, voter: tx-sender })) ERR_ALREADY_VOTED)
    (map-set votes
      { proposal-id: proposal-id, voter: tx-sender }
      { amount: amount, vote: vote-for }
    )
    (map-set proposals
      { proposal-id: proposal-id }
      (merge proposal {
        votes-for: (if vote-for (+ (get votes-for proposal) amount) (get votes-for proposal)),
        votes-against: (if vote-for (get votes-against proposal) (+ (get votes-against proposal) amount))
      })
    )
    (ok true)
  )
)

(define-public (end-proposal (proposal-id uint))
  (let
    ((proposal (unwrap! (get-proposal proposal-id) ERR_NOT_FOUND)))
    (asserts! (>= block-height (get end-block proposal)) ERR_UNAUTHORIZED)
    (map-set proposals
      { proposal-id: proposal-id }
      (merge proposal {
        status: (if (> (get votes-for proposal) (get votes-against proposal)) "passed" "rejected")
      })
    )
    (ok true)
  )
)

(define-read-only (get-all-proposals)
  (ok (var-get proposal-nonce))
)

