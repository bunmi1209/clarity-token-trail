;; TokenTrail - Track token transfers
(define-map transfers uint {
    from: principal,
    to: principal, 
    amount: uint,
    timestamp: uint
})

(define-map address-transfer-count principal uint)

(define-data-var transfer-nonce uint u0)

;; Record a new transfer
(define-public (record-transfer (from principal) (to principal) (amount uint))
    (let
        (
            (transfer-id (var-get transfer-nonce))
            (current-count-from (default-to u0 (map-get? address-transfer-count from)))
            (current-count-to (default-to u0 (map-get? address-transfer-count to)))
        )
        (try! (map-set transfers transfer-id {
            from: from,
            to: to,
            amount: amount,
            timestamp: block-height
        }))
        (map-set address-transfer-count from (+ current-count-from u1))
        (map-set address-transfer-count to (+ current-count-to u1))
        (var-set transfer-nonce (+ transfer-id u1))
        (ok transfer-id)
    )
)

;; Get number of transfers for an address
(define-read-only (get-transfer-count (address principal))
    (ok (default-to u0 (map-get? address-transfer-count address)))
)

;; Get transfer details by ID
(define-read-only (get-transfer-details (transfer-id uint))
    (ok (map-get? transfers transfer-id))
)

;; Get list of transfer IDs for an address (limited to last 50)
(define-read-only (get-transfer-history (address principal))
    (let
        (
            (total-transfers (var-get transfer-nonce))
        )
        (ok (filter-transfer-ids address total-transfers))
    )
)

;; Helper function to filter transfer IDs for an address
(define-private (filter-transfer-ids (address principal) (current-id uint))
    (if (or (is-eq current-id u0) (is-eq (len (get-transfers-list address current-id)) u50))
        (get-transfers-list address current-id)
        (filter-transfer-ids address (- current-id u1))
    )
)

;; Helper function to get list of transfers
(define-private (get-transfers-list (address principal) (current-id uint))
    (let
        (
            (transfer (map-get? transfers current-id))
        )
        (if (and
                (is-some transfer)
                (or
                    (is-eq (get from (unwrap-panic transfer)) address)
                    (is-eq (get to (unwrap-panic transfer)) address)
                )
            )
            (append (get-transfers-list address (- current-id u1)) (list current-id))
            (get-transfers-list address (- current-id u1))
        )
    )
)