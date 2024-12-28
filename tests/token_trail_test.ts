import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can record a transfer and get transfer details",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('token_trail', 'record-transfer', [
        types.principal(wallet1.address),
        types.principal(wallet2.address),
        types.uint(1000)
      ], wallet1.address)
    ]);
    
    // Check transfer was recorded successfully
    const transferId = block.receipts[0].result.expectOk();
    
    // Get transfer details
    block = chain.mineBlock([
      Tx.contractCall('token_trail', 'get-transfer-details', [
        transferId
      ], wallet1.address)
    ]);
    
    const transfer = block.receipts[0].result.expectOk().expectSome();
    assertEquals(transfer['from'], wallet1.address);
    assertEquals(transfer['to'], wallet2.address);
    assertEquals(transfer['amount'], types.uint(1000));
  }
});

Clarinet.test({
  name: "Can get transfer count and history",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    // Record multiple transfers
    let block = chain.mineBlock([
      Tx.contractCall('token_trail', 'record-transfer', [
        types.principal(wallet1.address),
        types.principal(wallet2.address),
        types.uint(1000)
      ], wallet1.address),
      Tx.contractCall('token_trail', 'record-transfer', [
        types.principal(wallet2.address),
        types.principal(wallet1.address),
        types.uint(500)
      ], wallet2.address)
    ]);
    
    // Check transfer count
    block = chain.mineBlock([
      Tx.contractCall('token_trail', 'get-transfer-count', [
        types.principal(wallet1.address)
      ], wallet1.address)
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), types.uint(2));
    
    // Check transfer history
    block = chain.mineBlock([
      Tx.contractCall('token_trail', 'get-transfer-history', [
        types.principal(wallet1.address)
      ], wallet1.address)
    ]);
    
    const history = block.receipts[0].result.expectOk();
    assertEquals(history.length, 2);
  }
});