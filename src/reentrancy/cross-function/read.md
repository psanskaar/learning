# Reentrancy: Cross-Function

## What this folder covers

A staking contract where claiming rewards is supposed to lock the staker's principal for 7 days. An attacker claims their reward and withdraws their full stake in the same transaction, before the lock is ever written, bypassing a restriction that applies to honest users.

## The vulnerability

`withdraw_rewards()` zeros the rewards balance and makes an external send before writing `time_of_unlock`. While that send is pending, the attacker's `receive()` calls `withdraw_staked()`. At that moment `time_of_unlock` is still `0`, and `block.timestamp > 0` is always true, so the lock check passes. The full staked balance goes out. Control returns to `withdraw_rewards()`, which then writes `time_of_unlock = block.timestamp + 7 days` on an account that no longer has anything staked.

## Why this bypasses the lock

The lock is written after an external call. Any code that runs during that call executes before the lock exists. `withdraw_staked()` has no way of knowing that `withdraw_rewards()` is paused mid-execution and about to apply a restriction. It checks the current state of `time_of_unlock`, sees zero, and proceeds normally.

## What the test shows

The attacker stakes 100 ETH, calls `withdraw_rewards()`, re-enters `withdraw_staked()` from inside `receive()`, and walks away with 110 ETH in one transaction. The `hasAttacked` guard in `receive()` ensures `withdraw_staked()` is only called once, isolating the cross-function mechanism from any same-function recursion through `withdraw_staked()` itself.

Before the attack:
- staked: 0, rewards: 0, unlock: 0, attacker balance: 100 ETH

After the attack:
- staked: 0, rewards: 0, unlock: set to 7 days from now (on an empty account), attacker balance: 110 ETH

## staking_fixed.sol

Moves `time_of_unlock` assignment to before the external send in `withdraw_rewards()`. The attack reverts because `withdraw_staked()` now sees a future `time_of_unlock` during the reentrant call, and the lock check correctly blocks it.

## Root cause

`withdraw_rewards()` makes an external call before writing the state that `withdraw_staked()` depends on. The two functions share a precondition through `time_of_unlock`, and reentrancy lets both execute against the same pre-update state before either has finished.