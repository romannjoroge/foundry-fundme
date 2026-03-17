//SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import {FundMe} from "../src/FundMe.sol";
import {Test} from "forge-std/Test.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumUSDAmount() view public {
        assertEq(fundMe.MINIMUM_CONTRIBUTION(), 5e18);
    }

    function testOwnerIsDeployer() view public {
        assertEq(fundMe.I_OWNER(), msg.sender);
    }

    function testAggregatorWorksWell() view public {
        assertEq(fundMe.getVersion(), 4);
    }
}
