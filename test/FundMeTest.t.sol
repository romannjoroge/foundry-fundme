//SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import {FundMe} from "../src/FundMe.sol";
import {Test} from "forge-std/Test.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant FUND_AMOUNT = 0.1 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUSDAmount() view public {
        assertEq(fundMe.MINIMUM_CONTRIBUTION(), 5e18);
    }

    function testOwnerIsDeployer() view public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testAggregatorWorksWell() view public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsIfLessThanMinimumUSD() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundSucceedsAndUpdatesDataStructures() public {
        vm.prank(USER);
        fundMe.fund{value: FUND_AMOUNT}();
        uint256 amountFunded = fundMe.getAmountAddressHasFunded(USER);
        assertEq(amountFunded, FUND_AMOUNT);
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: FUND_AMOUNT}();
        _;
    }

    function testOwnerOnlyCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWorks() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        // Action
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Arrange
        uint256 endContractBalance = address(fundMe).balance;
        assertEq(endContractBalance, 0);
        uint256 endOwnerBalance = fundMe.getOwner().balance;
        assertEq(endOwnerBalance, startingOwnerBalance + startingContractBalance);
    }

    function testMultipleWithdrawWorks() public funded {
        // Arrange
        uint160 totalFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < totalFunders; i++) {
            hoax(address(i), FUND_AMOUNT);
            fundMe.fund{value: FUND_AMOUNT}();
        }

        uint256 fundedContractBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Action
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 drainedContractBalance = address(fundMe).balance;
        assertEq(drainedContractBalance, 0);
        uint256 fundedOwnerBalance = fundMe.getOwner().balance;
        assertEq(fundedOwnerBalance, startingOwnerBalance + fundedContractBalance);
    }
}
