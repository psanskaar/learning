# learning

A working collection of smart contract vulnerabilities, built, broken, and exploited by hand while training toward smart contract security auditing. Every bug here has a vulnerable contract and a Foundry test that proves the exploit actually works, including cases where the obvious attack turns out not to work, and why.

## What's here

| Category | Contract(s) | Result | Finding |
|---|---|---|---|
| Reentrancy: textbook | `reentrancy/textbook/textbook.sol` | Does not drain | Subtraction-based withdrawal ledger. Repeated reentrant calls underflow on unwind. Solidity 0.8+ reverts before you can extract more than your entitlement, since over-extracting via fixed-amount subtraction is an underflow by definition. |
| Reentrancy: textbook | `reentrancy/textbook/airdrop.sol` | Exploitable | One-time claim flag, no arithmetic involved. Booleans don't underflow, so repeated reentrant claims drain a fixed-reward pool with nothing to stop them. |
| Reentrancy: cross-function | `reentrancy/cross-function/staking.sol` | Exploitable | Claiming a reward locks the stake for 7 days. Reentrancy claims the reward and withdraws the full stake in one transaction, before the lock is ever written. |
| Access control: missing modifier | `access-control/textbook/funding.sol` | Exploitable | `withdraw_all()` has no access control. Any address drains the full contract balance in one call. The `onlyOwner` modifier exists and is applied elsewhere in the same contract. |

## Running it

```bash
forge test -vvv
```

Every finding has a matching test. Every folder has a fixed version of the vulnerable contract alongside it.

## Methodology

Each contract isolates one root cause. Where a result could be confused with a different bug, the victim contract is fixed so that path is structurally closed, not just left untried by the attacker.

## Coming next

- Cross-contract reentrancy
- Read-only reentrancy
- tx.origin authentication bypass
- Unprotected initializer
- Arithmetic / precision
- Oracle manipulation

## About

Built while working through Cyfrin Updraft's Solidity, Foundry, and smart contract security curriculum.