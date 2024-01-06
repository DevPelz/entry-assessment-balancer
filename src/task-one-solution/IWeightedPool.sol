// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.23;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IRateProvider} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/pool-utils/IRateProvider.sol";

interface IWeightedPoolFactory {
    function create(
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256[] memory normalizedWeights,
        IRateProvider[] memory rateProviders,
        uint256 swapFeePercentage,
        address owner,
        bytes32 salt
    ) external returns (address);
}
