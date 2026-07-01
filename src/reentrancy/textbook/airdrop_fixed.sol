//SPDX-License-Identifier: MIT
// EXAMPLE OF MOST BASIC REENTRANCY CONTRACT SIMILAR TO TEXTBOOK

/*

A HONEST USER CAN JUST CLAIM THE AIRDROP ONCE MEANWHILE AN ATTACKER CAN EMPTY THE ENTIRE AIRDROP FUNDS

THIS FIXED VERSION USES CLASSIC CEI PATTERN TO FIX THE BUG, TO TEST THE FIXED VERSION SIMPLY REPLACE THE PATH IN POC TEST
FROM airdrop.sol TO airdrop_fixed.sol

CHANGES: ; record[msg.sender] = "claimed"; ,is executed before call


*/

pragma solidity ^0.8.0;

contract airdrop {
    mapping(address => string) public record;

    function eligible() public {
        require(keccak256(bytes(record[msg.sender])) != keccak256(bytes("claimed")), "already claimed");
        record[msg.sender] = "eligible";
    }

    function withdraw() public {
        require(keccak256(bytes(record[msg.sender])) == keccak256(bytes("eligible")), "not eligible for withdrawal");
        record[msg.sender] = "claimed";
        (bool success,) = msg.sender.call{value: 1 ether}("");
        require(success, "withdrawal failled");
    }

    receive() external payable {}
}
