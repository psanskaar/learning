//SPDX-License-Identifier: MIT
/*

A HONEST USER CAN ONLY WITHDRAW WHAT HE DONATED BUT AN ATTACKER CAN EMPTY THE CONTRACT FUNDS DUE TO THE ABSENCE OF onlyOwner
modifer in withdraw_all function

THIS FIXED VERSION SIMPLY ADDS THE ABSENT onlyOwner MODIFIER ON withdraw_all making the attack redundant

CHANGES: function withdraw_all() public onlyOwner{ , onlyOwner modifier added

*/

pragma solidity ^0.8.0;

contract funding {
    mapping(address => uint256) public records;
    uint256 private count;
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Action not permitted");
        _;
    }

    function deposit() public payable {
        records[msg.sender] += msg.value;
        count += msg.value;
    }

    function withdraw() public {
        require(records[msg.sender] > 0, "Nothing to withdraw");
        uint256 to_send = records[msg.sender];
        count -= records[msg.sender];
        records[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: to_send}("");
        require(success, "Withdrawl Failed");
    }

    function check_total() public view returns (uint256) {
        return count / 1e18;
    }

    function transfer_assets(address To, uint256 amount) public onlyOwner {
        (bool success,) = payable(To).call{value: amount}("");
        require(success, "Withdrawl failed");
    }

    function withdraw_all() public onlyOwner {
        uint256 to_send = count;
        count = 0;
        (bool success,) = msg.sender.call{value: to_send}("");
        require(success, "Withdrawl failed");
    }

    receive() external payable {}
}
