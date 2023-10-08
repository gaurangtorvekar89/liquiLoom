// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {CometStructs} from "./CompoundV3CometLibrary.sol";

interface Comet {
    function baseScale() external view returns (uint256);
    function supply(address asset, uint256 amount) external;
    function withdraw(address asset, uint256 amount) external;

    function getSupplyRate(uint256 utilization) external view returns (uint256);
    function getBorrowRate(uint256 utilization) external view returns (uint256);

    function getAssetInfoByAddress(address asset) external view returns (CometStructs.AssetInfo memory);
    function getAssetInfo(uint8 i) external view returns (CometStructs.AssetInfo memory);

    function getPrice(address priceFeed) external view returns (uint128);

    function userBasic(address) external view returns (CometStructs.UserBasic memory);
    function totalsBasic() external view returns (CometStructs.TotalsBasic memory);
    function userCollateral(address, address) external view returns (CometStructs.UserCollateral memory);

    function baseTokenPriceFeed() external view returns (address);

    function numAssets() external view returns (uint8);

    function getUtilization() external view returns (uint256);

    function baseTrackingSupplySpeed() external view returns (uint256);
    function baseTrackingBorrowSpeed() external view returns (uint256);

    function totalSupply() external view returns (uint256);
    function totalBorrow() external view returns (uint256);

    function baseIndexScale() external pure returns (uint64);

    function totalsCollateral(address asset) external view returns (CometStructs.TotalsCollateral memory);

    function baseMinForRewards() external view returns (uint256);
    function baseToken() external view returns (address);
}

interface CometRewards {
    function getRewardOwed(address comet, address account) external returns (CometStructs.RewardOwed memory);
    function claim(address comet, address src, bool shouldAccrue) external;
}

interface ERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint256);
}
