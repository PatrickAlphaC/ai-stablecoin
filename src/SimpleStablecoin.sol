// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/utils/math/SafeMath.sol";
import "chainlink-contracts/v0.8/interfaces/AggregatorV3Interface.sol";

contract SimpleStablecoin is ERC20 {
    using SafeMath for uint256;

    address public admin;
    IERC20 public collateralToken;
    AggregatorV3Interface public priceFeed;

    uint256 public constant COLLATERAL_RATIO_PRECISION = 1e18;

    constructor(
        address _collateralToken,
        address _priceFeed
    ) ERC20("Simple Stablecoin", "SST") {
        require(
            _collateralToken != address(0),
            "Invalid collateral token address"
        );
        require(_priceFeed != address(0), "Invalid price feed address");
        admin = msg.sender;
        collateralToken = IERC20(_collateralToken);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function getCollateralPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        return uint256(price);
    }

    function calculateCollateralAmount(
        uint256 _stablecoinAmount
    ) public view returns (uint256) {
        uint256 collateralPrice = getCollateralPrice();
        return
            _stablecoinAmount.mul(COLLATERAL_RATIO_PRECISION).div(
                collateralPrice
            );
    }

    function mint(uint256 _stablecoinAmount) external {
        require(_stablecoinAmount > 0, "Invalid stablecoin amount");

        uint256 collateralAmount = calculateCollateralAmount(_stablecoinAmount);
        collateralToken.transferFrom(
            msg.sender,
            address(this),
            collateralAmount
        );
        _mint(msg.sender, _stablecoinAmount);
    }

    function burn(uint256 _stablecoinAmount) external {
        require(_stablecoinAmount > 0, "Invalid stablecoin amount");

        uint256 collateralAmount = calculateCollateralAmount(_stablecoinAmount);
        _burn(msg.sender, _stablecoinAmount);
        collateralToken.transfer(msg.sender, collateralAmount);
    }
}
