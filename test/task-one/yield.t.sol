// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {IBasePool} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/vault/IBasePool.sol";
import {CreatePool} from "../../src/task-one-solution/createPool.sol";
import {Yield} from "../../src/task-one-solution/yield.sol";
import {Token} from "../../src/task-one-solution/token.sol";
import {WrapperToken} from "../../src/task-one-solution/wrappedToken.sol";
import {IVault} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/vault/IVault.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract YieldTest is Test {
    Token tokenA;
    Token tokenB;
    WrapperToken wtA;
    WrapperToken wtB;
    Yield yield;
    IBasePool basePool;

    address tester = makeAddr("tester");

    function setUp() public {
        tokenA = new Token();
        tokenB = new Token();

        yield = new Yield(
            address(tokenA),
            address(tokenB),
            0x230a59F4d9ADc147480f03B0D3fFfeCd56c3289a
        );

        basePool = IBasePool(yield._pool());
    }

    function testInitialize() public {
        // mint tokens
        tokenA.mint{value: 1 ether}();
        tokenB.mint{value: 1 ether}();

        uint amtA = tokenA.balanceOf(address(this));
        uint amtB = tokenA.balanceOf(address(this));

        // approve tokens
        tokenA.approve(address(yield.wrappedToken1()), amtA);
        tokenB.approve(address(yield.wrappedToken2()), amtB);

        // initialize
        bytes32 poolId_ = basePool.getPoolId();
        yield.initializePool(poolId_, amtA, amtB);
    }

    function testDeposit() public {
        testInitialize();

        vm.deal(tester, 4 ether);
        vm.startPrank(tester);
        // mint tokens
        tokenA.mint{value: 1 ether}();
        tokenB.mint{value: 1 ether}();

        uint amtA = tokenA.balanceOf(address(this));
        uint amtB = tokenA.balanceOf(address(this));

        // approve tokens
        tokenA.approve(address(yield.wrappedToken1()), amtA);
        tokenB.approve(address(yield.wrappedToken2()), amtB);

        yield.deposit(amtA, amtB);
        vm.stopPrank();
    }
}
