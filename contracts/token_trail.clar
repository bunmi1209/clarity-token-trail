;; TokenTrail - Track token transfers
(define-map transfers uint {
    from: principal,
    to: principal, 
    amount: uint,
    timestamp: uint,
    memo: (optional (string-utf8 256))
})

(define-map address-transfer-count principal uint)
(define-map address-total-sent principal uint)
(define-map address-total-received principal uint)

(define-data-var transfer-nonce uint u0)

;; Record a new transfer
(define-public (record-transfer (from principal) (to principal) (amount uint) (memo (optional (string-utf8 256))))
    (let
        (
            (transfer-id (var-get transfer-nonce))
            (current-count-from (default-to u0 (map-get? address-transfer-count from)))
            (current-count-to (default-to u0 (map-get? address-transfer-count to)))
            (current-sent (default-to u0 (map-get? address-total-sent from)))
            (current-received (default-to u0 (map-get? address-total-received to)))
        )
        (try! (map-set transfers transfer-id {
            from: from,
            to: to,
            amount: amount,
            timestamp: block-height,
            memo: memo
        }))
        (map-set address-transfer-count from (+ current-count-from u1))
        (map-set address-transfer-count to (+ current-count-to u1))
        (map-set address-total-sent from (+ current-sent amount))
        (map-set address-total-received to (+ current-received amount))
        (var-set transfer-nonce (+ transfer-id u1))
        (ok transfer-id)
    )
)

;; Get number of transfers for an address
(define-read-only (get-transfer-count (address principal))
    (ok (default-to u0 (map-get? address-transfer-count address)))
)

;; Get total amount sent by address
(define-read-only (get-total-sent (address principal))
    (ok (default-to u0 (map-get? address-total-sent address)))
)

;; Get total amount received by address
(define-read-only (get-total-received (address principal))
    (ok (default-to u0 (map-get? address-total-received address)))
)

;; Get transfer details by ID
(define-read-only (get-transfer-details (transfer-id uint))
    (ok (map-get? transfers transfer-id))
)

;; Search transfers by amount range
(define-read-only (search-transfers-by-amount (min-amount uint) (max-amount uint))
    (let
        ((total-transfers (var-get transfer-nonce)))
        (ok (filter-by-amount min-amount max-amount total-transfers))
    )
)

;; Helper function to filter transfers by amount
(define-private (filter-by-amount (min-amount uint) (max-amount uint) (current-id uint))
    (let
        ((transfer (map-get? transfers current-id)))
        (if (and
                (is-some transfer)
                (>= (get amount (unwrap-panic transfer)) min-amount)
                (<= (get amount (unwrap-panic transfer)) max-amount)
            )
            (append (filter-by-amount min-amount max-amount (- current-id u1)) (list current-id))
            (if (> current-id u0)
                (filter-by-amount min-amount max-amount (- current-id u1))
                (list)
            )
        )
    )
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
            (if (> current-id u0)
                (get-transfers-list address (- current-id u1))
                (list)
            )
        )
    )
)
