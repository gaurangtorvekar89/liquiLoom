// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPool} from "../utils/interfaces/IPool.sol";
import {Comet, ERC20} from "../utils/interfaces/CompoundV3Interface.sol";

// Compound v3 solidity example - https://github.com/compound-developers/compound-3-developer-faq/blob/master/contracts/MyContract.sol
contract YieldExecutor {
    IPool AaveV3Pool;
    Comet compoundV3Comet;

    enum Protocol {
        AaveV3,
        CompoundV3
    }

    constructor(address _aaveV3Pool, address _cometAddress) {
        AaveV3Pool = IPool(_aaveV3Pool);
        compoundV3Comet = Comet(_cometAddress);
    }

    struct Strategy {
        address[] assets;
        uint256[] amounts;
        address onBehalfOf;
    }

    function supplyAaveV3(Strategy memory strategy) external {
        for (uint256 i = 0; i < strategy.assets.length; i++) {
            ERC20 asset = ERC20(strategy.assets[i]);
            asset.approve(address(AaveV3Pool), strategy.amounts[i]);
            AaveV3Pool.supply(strategy.assets[i], strategy.amounts[i], strategy.onBehalfOf, 0);
        }
    }

    function supplyCompoundV3(Strategy memory strategy) external {
        for (uint256 i = 0; i < strategy.assets.length; i++) {
            ERC20 asset = ERC20(strategy.assets[i]);
            asset.approve(address(compoundV3Comet), strategy.amounts[i]);
            compoundV3Comet.supply(strategy.assets[i], strategy.amounts[i]);
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
