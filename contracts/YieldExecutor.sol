// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPool} from "../utils/interfaces/IPool.sol";
import {Comet, ERC20} from "../utils/interfaces/CompoundV3Interface.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

// Compound v3 solidity example - https://github.com/compound-developers/compound-3-developer-faq/blob/master/contracts/MyContract.sol
contract YieldExecutor {
    IPool AaveV3Pool;
    Comet compoundV3Comet;
    ISwapRouter public uniswapV3Router;
    IUniswapV3Factory public uniswapV3Factory;

    enum Protocol {
        AaveV3,
        CompoundV3
    }

    constructor(address _aaveV3Pool, address _cometAddress, address _uniswapV3Router, address _uniswapV3Factory) {
        AaveV3Pool = IPool(_aaveV3Pool);
        compoundV3Comet = Comet(_cometAddress);
        uniswapV3Router = ISwapRouter(_uniswapV3Router);
        uniswapV3Factory = IUniswapV3Factory(_uniswapV3Factory);
    }

    struct Strategy {
        address[] assets;
        uint256[] amounts;
        address onBehalfOf;
    }

    function swapExactOutput(address tokenIn, address tokenOut, uint256 amountOut) internal {
        uint24 fee = 3000; // Assuming a 0.3% fee tier
        uint256 deadline = block.timestamp + 15; // 15 seconds from the current block timestamp

        // Approve the Uniswap V3 Router to spend the input token on behalf of this contract
        ERC20(tokenIn).approve(address(uniswapV3Router), type(uint256).max); // Approve the maximum possible amount for simplicity

        uniswapV3Router.exactOutputSingle(
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: fee,
                recipient: address(this),
                deadline: deadline,
                amountOut: amountOut,
                amountInMaximum: type(uint256).max, // Set the maximum possible amount for simplicity
                sqrtPriceLimitX96: 0
            })
        );
    }

    function supplyAaveV3(Strategy memory strategy) external {
        for (uint256 i = 0; i < strategy.assets.length; i++) {
            address tokenIn = 0xf1E3A5842EeEF51F2967b3F05D45DD4f4205FF40;
            address tokenOut = strategy.assets[i];
            uint256 amountOut = strategy.amounts[i];

            swapExactOutput(tokenIn, tokenOut, amountOut);

            ERC20 asset = ERC20(strategy.assets[i]);
            uint256 assetBalance = asset.balanceOf(address(this));

            if (assetBalance >= strategy.amounts[i]) {
                asset.approve(address(AaveV3Pool), strategy.amounts[i]);
                AaveV3Pool.supply(strategy.assets[i], strategy.amounts[i], strategy.onBehalfOf, 0);
            }
        }
    }

    function supplyCompoundV3(Strategy memory strategy) external {
        for (uint256 i = 0; i < strategy.assets.length; i++) {
            address tokenIn = 0xf1E3A5842EeEF51F2967b3F05D45DD4f4205FF40;
            address tokenOut = strategy.assets[i];
            uint256 amountOut = strategy.amounts[i];

            swapExactOutput(tokenIn, tokenOut, amountOut);

            ERC20 asset = ERC20(strategy.assets[i]);
            uint256 assetBalance = asset.balanceOf(address(this));
            if (assetBalance >= strategy.amounts[i]) {
                asset.approve(address(compoundV3Comet), strategy.amounts[i]);
                compoundV3Comet.supply(strategy.assets[i], strategy.amounts[i]);
            }
        }
    }

    function withdrawAavev3(Strategy memory strategy) external {
        for (uint256 i = 0; i < strategy.assets.length; i++) {
            AaveV3Pool.withdraw(strategy.assets[i], strategy.amounts[i], strategy.onBehalfOf);
        }
    }

    function withdrawCompoundV3(Strategy memory strategy) external {
        for (uint256 i = 0; i < strategy.assets.length; i++) {
            compoundV3Comet.withdraw(strategy.assets[i], strategy.amounts[i]);
        }
    }
}
