//SPDX-License-Identifier: MIT
//THIS ONLY WORKS PRECISELY FOR VALUES WITH PRRFECT DIVISION BY 10,FOR EXAMPLE 100 ETH STAKED

/*

A HONEST USER HAS HIS ACCOUNT BALANCE WITHDRAWL LOCKED FOR 7 DAYS AFTER WITHDRAWING REWARDS MEANWHILE AN ATTACKER CAN SIMPLY
RENTER AND CALL WITHDRAW STAKED AND BYPASS THE RESTRICTION

*/

pragma solidity ^0.8.0;

contract staking {
    uint256 public immutable reward_percentage;

    constructor() {
        reward_percentage = 10;
    }

    struct user {
        address userAddress;
        uint256 staked;
        uint256 rewards;
        uint256 time_of_unlock;
    }

    mapping(address => user) public users;

    function stake() public payable returns (string memory) {
        require(msg.value >= 10 ether, "Minimum 10 ether required for staking");
        if (msg.sender != users[msg.sender].userAddress) {
            users[msg.sender] = user(msg.sender, msg.value, (msg.value / reward_percentage), 0);
        } else {
            users[msg.sender].staked += msg.value;
            users[msg.sender].rewards += (msg.value / reward_percentage);
        }
        return "staked successfully";
    }

    function withdraw_staked() public returns (string memory) {
        require(
            block.timestamp > users[msg.sender].time_of_unlock && users[msg.sender].staked > 0,
            "Insufficient funds or Withdraw locked"
        );
        uint256 bal = users[msg.sender].staked;
        users[msg.sender].staked = 0;
        (bool success,) = msg.sender.call{value: bal}("");
        require(success, "withdrawal failed");
        users[msg.sender].rewards = 0;

        return "withdrawal successful";
    }

    function check_rewards() public view returns (uint256) {
        return users[msg.sender].rewards;
    }

    function check_staked() public view returns (uint256) {
        return users[msg.sender].staked;
    }

    function withdraw_rewards() public returns (string memory) {
        require(users[msg.sender].rewards > 0, "insufficient funds");
        uint256 bal = users[msg.sender].rewards;
        users[msg.sender].rewards = 0;
        (bool success,) = msg.sender.call{value: bal}("");
        require(success, "withdrawal failed");
        users[msg.sender].time_of_unlock = block.timestamp + 7 days;
        return "withdrawal successful";
    }

    receive() external payable {}
}
