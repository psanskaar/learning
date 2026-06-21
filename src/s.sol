// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract S {
    mapping(address => uint256) public balances;
    function deposit(uint256 amount) public payable {
        require(msg.value == amount, "mismatched amount");
        balances[msg.sender] += amount;

    }

    function check() public view returns(uint256){
        return balances[msg.sender];
    }
}
