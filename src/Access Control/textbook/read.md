# Access Control: Missing Modifier

## What this folder covers

A funding vault where users can deposit ETH and withdraw their own contributions. The contract has an `onlyOwner` modifier and uses it correctly on `transfer_assets()` and `check_total()`. It does not use it on `withdraw_all()`, which sends the entire contract balance to whoever calls it.

## The vulnerability

`withdraw_all()` has no access control. Any address, including a contract with no prior relationship to the vault, can call it and receive the full balance. There is no check on `msg.sender`, no ownership requirement, nothing. The function runs for anyone.

## What the test proves

`poc_funding.t.sol` sets up two honest users depositing 100 ETH and 200 ETH respectively. Honest user 1 withdraws their own deposit via `withdraw()`, which works correctly. The attacker contract then calls `withdraw_all()` and receives honest user 2's 200 ETH in full.

The proof is both directional: `withdraw()` correctly limits a user to their own balance, and `withdraw_all()` correctly illustrates what happens when the privileged function has no guard at all.

## Known secondary issue

`withdraw_all()` does not zero individual user records in the mapping. After the drain, `records[honest_user2]` still shows 200 ETH. If honest user 2 calls `withdraw()` after the vault is empty, the balance check passes but the transfer fails because there is nothing left to send. Their funds are gone and their records entry is permanently stale.

Fixing this properly would require maintaining a separate iterable array of depositor addresses and looping through it in `withdraw_all()`, which adds gas complexity and a griefing surface. This is left unfixed intentionally to keep the demonstration focused on the access control finding. It is documented here as a known, understood limitation rather than an oversight.

## funding_fixed.sol

Adds `onlyOwner` to `withdraw_all()`. One modifier. The attack reverts with "Action not permitted" when called from any address other than the deployer.

## Root cause

A privileged function was written without an access control check. The `onlyOwner` modifier existed in the contract and was applied correctly elsewhere. The bug is a missing application of an already-present pattern, which is the most common shape this vulnerability takes in real code.