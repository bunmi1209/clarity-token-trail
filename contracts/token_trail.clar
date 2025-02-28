;; TokenTrail - Track token transfers

;; Constants for error handling
(define-constant ERR-ZERO-AMOUNT (err u100))
(define-constant ERR-AMOUNT-OVERFLOW (err u101))

;; Storage
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
        ;; Validate amount
        (asserts! (> amount u0) ERR-ZERO-AMOUNT)
        ;; Check for overflow
        (asserts! (< (+ current-sent amount) (pow u2 u128)) ERR-AMOUNT-OVERFLOW)
        (asserts! (< (+ current-received amount) (pow u2 u128)) ERR-AMOUNT-OVERFLOW)
        
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

[... rest of the contract with similar improvements ...]
