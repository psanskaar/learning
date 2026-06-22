// SPDX-License-Identifier: MIT

//DOESNT WORK, OVERFLOW PROTECTION IN SOLIDITY 0.8.0 MAY BE THE CAUSE 
pragma solidity ^0.8.0;

contract basic{
    mapping(address => uint256) public balances;

    function deposit(uint256 amount) public payable {
        require(msg.value == amount, "mismatched amount");
        balances[msg.sender] += amount;
    }

    function check() public view returns (uint256) {
        return balances[msg.sender];
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, " insufficient balance ");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "withdrawal failed ");
        balances[msg.sender] -= amount;
    }

    function receive() external payable {}
}
