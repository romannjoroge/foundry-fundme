//SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";

contract DeployFundMe is Script {
    function run() external returns(FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        vm.stopBroadcast();

        return fundMe;
    }
}