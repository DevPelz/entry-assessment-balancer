// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "./IWeightedPool.sol";

contract CreatePool {
    IWeightedPoolFactory pool;

    constructor(address _pool) {
        pool = IWeightedPoolFactory(_pool);
    }

    function create(
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256[] memory normalizedWeights,
        address owner
    ) external {
        pool.create(
            name,
            symbol,
            tokens,
            normalizedWeights,
            new IRateProvider[](2),
            300000000000000,
            owner,
            0x0
        );
    }
}
