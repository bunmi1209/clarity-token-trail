# TokenTrail

A Clarity smart contract for tracking token transfers on the Stacks blockchain. This contract maintains a history of token transfers between addresses and provides functionality to query transfer history.

## Features

- Track token transfers with timestamp, amount, and optional memo
- Query transfer history by address
- Search transfers by amount range
- Track total sent and received amounts per address
- Get total number of transfers for an address
- View transfer details

## Functions

- `record-transfer`: Records a token transfer between addresses with optional memo
- `get-transfer-count`: Gets total number of transfers for an address
- `get-total-sent`: Gets total amount sent by an address
- `get-total-received`: Gets total amount received by an address
- `get-transfer-history`: Returns transfer history for an address
- `get-transfer-details`: Gets details of a specific transfer
- `search-transfers-by-amount`: Search transfers within a specified amount range

## Usage

See the tests for example usage of the contract functions.

### Recording a Transfer with Memo

```clarity
(contract-call? .token-trail record-transfer tx-sender recipient u1000 (some u"Payment for services"))
```

### Searching Transfers by Amount

```clarity
(contract-call? .token-trail search-transfers-by-amount u1000 u5000)
```

### Getting Address Metrics

```clarity
(contract-call? .token-trail get-total-sent tx-sender)
(contract-call? .token-trail get-total-received tx-sender)
```
