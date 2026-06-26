# learning

A working collection of smart contract vulnerabilities, built, broken, and exploited by hand while training toward smart contract security auditing. Every bug here has a contract that's actually vulnerable and a Foundry test that actually proves it, including the cases where an "obvious" exploit turns out not to work, and why.

## Why this repo exists

Reading about a vulnerability class once and moving on doesn't build the instinct an auditor actually needs. This repo is the slower, more deliberate version: write the vulnerable contract from scratch, write the attacker from scratch, run it, and only move on once the result is fully explained, including the negative results. A test that fails for a reason you understand is worth more than ten contracts copied from a tutorial.

## What's here

| Category | Contract(s) | Result | Finding |
|---|---|---|---|
| Reentrancy: textbook | `reentrancy/textbook/textbook.sol` | ⚠️ Does not drain | Classic subtraction-based withdrawal ledger. Repeated reentrant calls underflow on unwind. Solidity 0.8+'s checked arithmetic forces a revert the moment you try to extract more than your ledger entitles you to, because over-extraction via fixed-amount subtraction *is* an underflow by definition. |
| Reentrancy: textbook | `reentrancy/textbook/airdrop.sol` | ✅ Exploitable | One-time claim-flag pattern, no arithmetic anywhere. A boolean has no floor to underflow into, so repeated reentrant claims drain a fixed-reward pool with nothing to stop them. |
| Reentrancy: cross-function | `reentrancy/cross-function/staking.sol` | ✅ Exploitable | Claiming a reward is supposed to lock the staker's principal for 7 days. A normal, honest user who claims and then tries to withdraw is correctly blocked. Reentrancy claims the reward and withdraws the full stake in the same transaction, before the lock is ever written, bypassing a security invariant that no honest sequence of calls can bypass. |

## Running it

```bash
forge test -vvv
```

Every finding above has a matching test. Where relevant, the test proves both halves: that an honest user is correctly blocked, *and* that reentrancy gets through anyway. The contrast is the actual evidence, not just the final balance.

## Methodology

Each contract is built to isolate exactly one root cause. Where a result could be confused with a different, unrelated bug (for instance, an attacker recursing into the same function it just exploited, rather than genuinely crossing into a second one), the victim contract is fixed so that path is structurally closed, not just left unattempted by a polite attacker. If an exploit succeeds, it's because the contract was incapable of stopping it, not because the attacker held back.

## Coming next

- Cross-contract reentrancy
- Read-only reentrancy
- Access control
- Arithmetic / precision (rounding and share-calculation errors, distinct from basic overflow)
- Oracle manipulation

## About

Built while working through Cyfrin Updraft's Solidity, Foundry, and smart contract security curriculum, toward a career in smart contract auditing.
