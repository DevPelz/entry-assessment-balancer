// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "./IWeightedPool.sol";

/**
 * @title CreatePool
 * @dev Contract for creating a new Weighted Pool using the provided factory.
 */
contract CreatePool {
    IWeightedPoolFactory pool;

    /**
     * @dev Constructor to set the Weighted Pool factory address.
     * @param _pool Address of the Weighted Pool factory contract.
     */
    constructor(address _pool) {
        pool = IWeightedPoolFactory(_pool);
    }

    /**
     * @dev Function to create a new Weighted Pool.
     * @param name Name of the new pool.
     * @param symbol Symbol of the new pool.
     * @param tokens Array of ERC20 tokens in the pool.
     * @param normalizedWeights Array of normalized weights corresponding to the tokens.
     * @param owner Address of the owner of the new pool.
     * @return Address of the newly created Weighted Pool.
     */
    function create(
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256[] memory normalizedWeights,
        address owner
    ) external returns (address) {
        return
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
