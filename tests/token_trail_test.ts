import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can record a transfer with memo and get transfer details",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('token_trail', 'record-transfer', [
        types.principal(wallet1.address),
        types.principal(wallet2.address),
        types.uint(1000),
        types.some(types.utf8("Test transfer"))
      ], wallet1.address)
    ]);
    
    const transferId = block.receipts[0].result.expectOk();
    
    block = chain.mineBlock([
      Tx.contractCall('token_trail', 'get-transfer-details', [
        transferId
      ], wallet1.address)
    ]);
    
    const transfer = block.receipts[0].result.expectOk().expectSome();
    assertEquals(transfer['from'], wallet1.address);
    assertEquals(transfer['to'], wallet2.address);
    assertEquals(transfer['amount'], types.uint(1000));
    assertEquals(transfer['memo'], types.some("Test transfer"));
  }
});

Clarinet.test({
  name: "Can search transfers by amount range",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('token_trail', 'record-transfer', [
        types.principal(wallet1.address),
        types.principal(wallet2.address),
        types.uint(500),
        types.none()
      ], wallet1.address),
      Tx.contractCall('token_trail', 'record-transfer', [
        types.principal(wallet1.address),
        types.principal(wallet2.address),
        types.uint(1000),
        types.none()
      ], wallet1.address)
    ]);
    
    block = chain.mineBlock([
      Tx.contractCall('token_trail', 'search-transfers-by-amount', [
        types.uint(700),
        types.uint(1500)
      ], wallet1.address)
    ]);
    
    const results = block.receipts[0].result.expectOk();
    assertEquals(results.length, 1);
  }
});

Clarinet.test({
  name: "Can track total sent and received amounts",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('token_trail', 'record-transfer', [
        types.principal(wallet1.address),
        types.principal(wallet2.address),
        types.uint(1000),
        types.none()
      ], wallet1.address)
    ]);
    
    block = chain.mineBlock([
      Tx.contractCall('token_trail', 'get-total-sent', [
        types.principal(wallet1.address)
      ], wallet1.address)
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), types.uint(1000));
    
    block = chain.mineBlock([
      Tx.contractCall('token_trail', 'get-total-received', [
        types.principal(wallet2.address)
      ], wallet2.address)
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), types.uint(1000));
  }
});
