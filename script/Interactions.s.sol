//SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant FUND_VALUE = 0.01 ether;
    function fundFundMe(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe fundMe = FundMe(payable(mostRecentDeployment));
        fundMe.fund{value: FUND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", FUND_VALUE);
    }

    function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentDeployment);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe fundMe = FundMe(payable(mostRecentDeployment));
        fundMe.withdraw();
        vm.stopBroadcast();
        console.log("Withdrawed from FundMe");
    }

    function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecentDeployment);
        vm.stopBroadcast();
    }
}