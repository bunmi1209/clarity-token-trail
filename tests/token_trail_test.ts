import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensures non-zero amount validation",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('token_trail', 'record-transfer', [
        types.principal(wallet1.address),
        types.principal(wallet2.address),
        types.uint(0),
        types.none()
      ], wallet1.address)
    ]);
    
    block.receipts[0].result.expectErr(100); // ERR-ZERO-AMOUNT
  }
});

Clarinet.test({
  name: "Prevents self-transfers",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('token_trail', 'record-transfer', [
        types.principal(wallet1.address),
        types.principal(wallet1.address),
        types.uint(1000),
        types.none()
      ], wallet1.address)
    ]);
    
    block.receipts[0].result.expectErr(102); // ERR-SELF-TRANSFER
  }
});
