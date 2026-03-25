//SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {PriceConverter} from "./libraries/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();
error FundMe__NotEnough();
error FundMe__NotSend();

contract FundMe {
    using PriceConverter for uint256;
    address private immutable I_OWNER;
    uint256 public constant MINIMUM_CONTRIBUTION = 5e18;
    
    mapping(address => uint256) private s_funderAmounts;
    address[] private s_funders;
    AggregatorV3Interface immutable private S_PRICE_FEED;

    constructor(address priceFeedAddress) {
        I_OWNER = msg.sender;
        S_PRICE_FEED = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        if (msg.value.convert(S_PRICE_FEED) < MINIMUM_CONTRIBUTION) {
            revert FundMe__NotEnough();
        }
        s_funderAmounts[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 i = 0; i < fundersLength; i++) {
            address funder = s_funders[i];
            s_funderAmounts[funder] = 0;
        }

        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        if (callSuccess == false) {
            revert FundMe__NotSend();
        }
    }

    function getVersion() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(S_PRICE_FEED);
        return priceFeed.version();
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != I_OWNER) {
            revert FundMe__NotOwner();
        }
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /*
    * View / Pure functions (Getters)
    */
    function getAmountAddressHasFunded(address fundingAddress) external view returns(uint256) {
        return s_funderAmounts[fundingAddress];
    }

    function getFunder(uint256 index) external view returns(address) {
        return s_funders[index];
    }

    function getOwner() external view returns(address) {
        return I_OWNER;
    }
}
