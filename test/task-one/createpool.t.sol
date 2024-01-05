// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {CreatePool} from "../../src/task-one-solution/createPool.sol";
import {Token} from "../../src/task-one-solution/token.sol";
import {IERC20} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/solidity-utils/openzeppelin/IERC20.sol";

contract CreatePoolTest is Test {
    CreatePool pool;
    Token tokenA;
    Token tokenB;

    function setUp() public {
        pool = new CreatePool(0x230a59F4d9ADc147480f03B0D3fFfeCd56c3289a);
        tokenA = new Token();
        tokenB = new Token();
    }

    function testCreatePool() public {
        IERC20[] memory _tokens = new IERC20[](2);
        uint256[] memory _amounts = new uint256[](2);
        uint amount = 1e18 / 2;

        _tokens[0] = IERC20(address(tokenA));
        _tokens[1] = IERC20(address(tokenB));

        _amounts[0] = amount;
        _amounts[1] = amount;

        pool.create("Balancer Pool", "BPT", _tokens, _amounts, address(this));
    }
}
