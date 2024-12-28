# TokenTrail

A Clarity smart contract for tracking token transfers on the Stacks blockchain. This contract maintains a history of token transfers between addresses and provides functionality to query transfer history.

## Features

- Track token transfers with timestamp and amount
- Query transfer history by address
- Get total number of transfers for an address
- View transfer details

## Functions

- `record-transfer`: Records a token transfer between addresses
- `get-transfer-count`: Gets total number of transfers for an address
- `get-transfer-history`: Returns transfer history for an address
- `get-transfer-details`: Gets details of a specific transfer

## Usage

See the tests for example usage of the contract functions.