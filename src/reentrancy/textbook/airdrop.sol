//SPDX-License-Identifier: MIT
// EXAMPLE OF MOST BASIC REENTRANCY CONTRACT SIMILAR TO TEXTBOOK

pragma solidity ^0.8.0;

contract airdrop {
    mapping(address => string) public record;

    function eligible() public {
        record[msg.sender] = "eligible";
    }

    function withdraw() public {
        require(keccak256(bytes(record[msg.sender])) == keccak256(bytes("eligible")), "not eligible for withdrawal");
        (bool success,) = msg.sender.call{value: 1 ether}("");
        record[msg.sender] = "claimed";
        require(success, "withdrawal failled");
    }

    receive() external payable {}
}
