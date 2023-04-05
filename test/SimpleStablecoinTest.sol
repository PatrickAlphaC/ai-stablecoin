// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SimpleStablecoin.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "../src/MockChainlinkAggregator.sol";
import "../src/MockERC20.sol";
import "openzeppelin-contracts/utils/math/SafeMath.sol";

contract SimpleStablecoinTest is Test {
    using SafeMath for uint256;
    SimpleStablecoin stablecoin;
    MockERC20 collateralToken;
    MockChainlinkAggregator mockPriceFeed;

    function setUp() public {
        collateralToken = new MockERC20("Mock Collateral", "MCK", 1e24); // Create a mock ERC20 token with 1 million tokens (assuming 18 decimals)
        mockPriceFeed = new MockChainlinkAggregator(1e18); // Assuming the initial price is 1 USD (1 * 10^8, since Chainlink uses 8 decimals)
        stablecoin = new SimpleStablecoin(
            address(collateralToken),
            address(mockPriceFeed)
        );
    }

    function test_OneDollarWorthOfCollateralMintsOneDollarWorthOfStablecoin()
        public
    {
        uint256 collateralAmount = 1e18; // Assuming 18 decimals for the collateral token
        uint256 collateralPrice = stablecoin.getCollateralPrice();
        uint256 expectedStablecoinAmount = collateralAmount.mul(1e18).div(
            collateralPrice
        );

        collateralToken.approve(address(stablecoin), type(uint256).max); // Approve the SimpleStablecoin contract to spend the collateral tokens
        collateralToken.mint(msg.sender, expectedStablecoinAmount);
        uint256 initialStablecoinBalance = stablecoin.balanceOf(address(this));
        stablecoin.mint(expectedStablecoinAmount);
        uint256 finalStablecoinBalance = stablecoin.balanceOf(address(this));

        assertEq(
            finalStablecoinBalance.sub(initialStablecoinBalance),
            expectedStablecoinAmount,
            "Minted stablecoin amount does not match the expected amount"
        );
    }
}
