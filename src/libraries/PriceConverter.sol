//SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function convert(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 priceEth = getPriceOfEthFromContract(priceFeed);
        return (priceEth * ethAmount) / 1e18;
    }

    function getPriceOfEthFromContract(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }
}
