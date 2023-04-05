// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "chainlink-contracts/v0.8/interfaces/AggregatorV3Interface.sol";

contract MockChainlinkAggregator is AggregatorV3Interface {
    int256 private price;
    uint80 private roundId;

    constructor(int256 _price) {
        price = _price;
        roundId = 1;
    }

    function decimals() external pure override returns (uint8) {
        return 8;
    }

    function description() external pure override returns (string memory) {
        return "Mock Chainlink Aggregator";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        override
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (_roundId, price, 1, 1, _roundId - 1);
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (roundId, price, 1, 1, roundId - 1);
    }

    function setPrice(int256 _price) public {
        price = _price;
        roundId++;
    }
}
