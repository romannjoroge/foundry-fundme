//SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function convert(uint256 ethAmount) internal view returns (uint256) {
        uint256 priceEth = getPriceOfEthFromContract();
        return (priceEth * ethAmount) / 1e18;
    }

    function getPriceOfEthFromContract() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }
}
