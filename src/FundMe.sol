//SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {PriceConverter} from "./libraries/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();
error FundMe__NotEnough();
error FundMe__NotSend();

contract FundMe {
    using PriceConverter for uint256;
    address public immutable I_OWNER;
    uint256 public constant MINIMUM_CONTRIBUTION = 5e18;
    mapping(address => uint256) funderAmounts;
    address[] public funders;
    AggregatorV3Interface immutable private S_PRICE_FEED;

    constructor(address priceFeedAddress) {
        I_OWNER = msg.sender;
        S_PRICE_FEED = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        if (msg.value.convert(S_PRICE_FEED) < MINIMUM_CONTRIBUTION) {
            revert FundMe__NotEnough();
        }
        funderAmounts[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            funderAmounts[funder] = 0;
        }

        funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        if (callSuccess == false) {
            revert FundMe__NotSend();
        }
    }

    function getVersion() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
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
}
