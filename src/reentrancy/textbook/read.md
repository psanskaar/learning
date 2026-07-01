# Reentrancy: Textbook

## What this folder covers

Two contracts demonstrating the same vulnerability class, same ordering mistake, but different outcomes depending on how the bookkeeping is structured. One fails to drain. One succeeds. Understanding why is the actual point.

## textbook.sol

A basic vault where users deposit ETH and withdraw it via `withdraw(uint256 amount)`. The function checks the balance, sends ETH via `.call`, and only decrements the ledger afterward.

**Why it does not drain under Solidity 0.8+**

The attacker re-enters `withdraw()` repeatedly before the balance is decremented. Each call sends a fixed `amount` out and then tries to run `balances[msg.sender] -= amount` on the way back up the call stack. The deepest call decrements fine: `1 - 1 = 0`. The next call up tries `0 - 1` on a `uint256`. Solidity 0.8+ has checked arithmetic by default, which means this underflows and reverts the entire call. That revert propagates up through every pending low-level `.call`, and the whole transaction rolls back. Nothing is stolen.

A contract compiled below 0.8, or using `unchecked{}`, would drain completely.

**The ordering mistake still exists.** The fix is Checks-Effects-Interactions: decrement the balance before making the external call, not after.


## airdrop.sol

An airdrop contract where each address can claim a fixed 1 ETH reward once. The guard is a string-based state flag in a mapping, set to "claimed" after the reward is sent. The ordering mistake, external call before state update, lets an attacker drain the entire pool in one transaction.

## The vulnerability

`withdraw()` sends 1 ETH via `.call` and only sets `record[msg.sender] = "claimed"` afterward. While the send is pending, the attacker's `receive()` function fires. At that moment, `record[msg.sender]` is still "eligible", so the require check in `withdraw()` passes and another 1 ETH goes out. This repeats until the balance condition in `receive()` stops the loop: `address(target).balance > msg.value` prevents a call when the contract can no longer pay a full 1 ETH, so the recursion exits cleanly rather than hitting a revert mid-chain.

## Why this drains when textbook.sol does not

`textbook.sol` uses a numeric ledger with subtraction. Repeated re-entry into a subtraction-based function eventually underflows under Solidity 0.8+, which reverts the whole transaction. This contract has no arithmetic. The state transition is a string assignment, which is idempotent regardless of how many times it eventually runs. Setting "claimed" five times in a row after five payouts has no different effect than setting it once. There is no arithmetic floor to crash into, so the protection that accidentally saved the textbook contract does not exist here.

## Simplification worth noting

`eligible()` has no access control. Any address can call it on themselves at any time to become eligible for the airdrop, with no allowlist, Merkle proof, or owner approval. In a real deployment, eligibility would be gated. This is left open intentionally to keep the demonstration focused on the reentrancy finding rather than adding a separate access control mechanism.

## The fix

Set `record[msg.sender] = "claimed"` before the external call. One line moved. The reentrant call would then fail the `require(keccak256(bytes(record[msg.sender])) == keccak256(bytes("eligible")))` check immediately on re-entry, since the flag is already updated.

## Root cause

State update happens after an external call. The contract assumed the call would complete and return before anything else could run. It cannot make that assumption when sending ETH to an unknown address.