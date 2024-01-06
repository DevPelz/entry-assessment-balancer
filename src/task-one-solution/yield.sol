// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/balancer-v2-monorepo/pkg/interfaces/contracts/vault/IAsset.sol";

import {IBasePool} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/vault/IBasePool.sol";
import {WeightedPoolUserData} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/pool-weighted/WeightedPoolUserData.sol";

import {IBalancerQueries} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/standalone-utils/IBalancerQueries.sol";

import "./wrappedToken.sol";

import {IVault} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/vault/IVault.sol";

import "./createPool.sol";

/**
 * @title Yield Contract
 * @dev A contract that facilitates the deposit and withdrawal of tokens to/from a Balancer pool,
 *      and tracks users' balances in the pool.
 */
contract Yield {
    IERC20 public token1;
    IERC20 public token2;

    IVault public constant vault =
        IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    IBalancerQueries public balancerQ =
        IBalancerQueries(0xE39B5e3B6D74016b2F6A9673D7d7493B6DF549d5);

    CreatePool public pool;

    IERC20[] _tokens = new IERC20[](2);

    WrapperToken public wrappedToken1;
    WrapperToken public wrappedToken2;
    address public _pool;
    IBasePool basepool;

    // mapping to track balances of each user
    mapping(address => uint256) public balances;

    /**
     * @dev Constructor to initialize the Yield contract.
     * @param _wrappedToken1 Address of the first wrapped token contract.
     * @param _wrappedToken2 Address of the second wrapped token contract.
     * @param _weightedPool Address of the weighted pool contract.
     */
    constructor(
        address _wrappedToken1,
        address _wrappedToken2,
        address _weightedPool
    ) {
        wrappedToken1 = new WrapperToken(address(_wrappedToken1));
        wrappedToken2 = new WrapperToken(address(_wrappedToken2));

        // store the IERC20 tokens
        token1 = IERC20(wrappedToken1);
        token2 = IERC20(wrappedToken2);
        // sort the adresses to ensure that we dont get BAL101 error when creatting pool

        if (token1 < token2) {
            _tokens[0] = token1;
            _tokens[1] = token2;
        } else {
            _tokens[0] = token2;
            _tokens[1] = token1;
        }

        // create the pool

        pool = new CreatePool(_weightedPool);

        uint256[] memory _amounts = new uint256[](2);
        uint amount = 1e18 / 2;

        _amounts[0] = amount;
        _amounts[1] = amount;

        _pool = pool.create(
            "GuildAuditsPool",
            "GAT",
            _tokens,
            _amounts,
            address(this)
        );

        basepool = IBasePool(_pool);
    }

    /**
     * @dev Function to convert ERC20 tokens to assets.
     * @param tokens An array of ERC20 token contracts.
     * @return assets An array of asset contracts.
     */
    function _convertERC20sToAssets(
        IERC20[] memory tokens
    ) internal pure returns (IAsset[] memory assets) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            assets := tokens
        }
    }

    /**
     * @dev Function to initialize the Balancer pool for a user.
     * @param _poolId Pool identifier.
     * @param _amount1 Amount of the first token to deposit.
     * @param _amount2 Amount of the second token to deposit.
     */

    function initializePool(
        bytes32 _poolId,
        uint _amount1,
        uint _amount2
    ) public {
        IAsset[] memory assets = _convertERC20sToAssets(_tokens);

        uint256[] memory maxAmountsIn = new uint256[](_tokens.length);

        bool fromInternalBalance = false;

        address sender = address(this);
        address recipient = msg.sender;

        // deposit wrapped tokens
        maxAmountsIn[0] = wrappedToken1.deposit(_amount1, recipient);
        maxAmountsIn[1] = wrappedToken2.deposit(_amount2, recipient);

        // approve vault to spend tokens
        bytes memory userData = abi.encode(
            WeightedPoolUserData.JoinKind.INIT,
            maxAmountsIn
        );

        // We need to create a JoinPoolRequest to tell the pool how we we want to add liquidity
        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest({
            assets: assets,
            maxAmountsIn: maxAmountsIn,
            userData: userData,
            fromInternalBalance: fromInternalBalance
        });

        wrappedToken1.approve(address(vault), _amount1);
        wrappedToken2.approve(address(vault), _amount2);

        // join pool

        vault.joinPool(_poolId, sender, recipient, request);
    }

    /**
     * @dev Function to deposit tokens into the Balancer pool.
     * @param tkn1AmtIn Amount of the first token to deposit.
     * @param tkn2AmtIn Amount of the second token to deposit.
     */
    function deposit(uint tkn1AmtIn, uint tkn2AmtIn) public {
        IAsset[] memory assets = _convertERC20sToAssets(_tokens);

        uint256[] memory maxAmountsIn = new uint256[](_tokens.length);

        bool fromInternalBalance = false;

        address sender = address(this);
        address recipient = msg.sender;

        // deposit wrapped tokens
        maxAmountsIn[0] = wrappedToken1.deposit(tkn1AmtIn, recipient);
        maxAmountsIn[1] = wrappedToken2.deposit(tkn2AmtIn, recipient);

        // approve vault to spend tokens
        bytes memory userData = abi.encode(
            WeightedPoolUserData.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT,
            maxAmountsIn,
            0
        );

        // We need to create a JoinPoolRequest to tell the pool how we we want to add liquidity
        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest({
            assets: assets,
            maxAmountsIn: maxAmountsIn,
            userData: userData,
            fromInternalBalance: fromInternalBalance
        });

        bytes32 _poolId = basepool.getPoolId();
        // query to know amount of tokens user will be expecting to recieve
        (uint tokensOut, uint[] memory amts) = balancerQ.queryJoin(
            _poolId,
            sender,
            recipient,
            request
        );

        request.maxAmountsIn = amts;

        wrappedToken1.approve(address(vault), tkn1AmtIn);
        wrappedToken2.approve(address(vault), tkn2AmtIn);

        // join pool
        vault.joinPool(_poolId, sender, sender, request);

        // update balance
        balances[msg.sender] += tokensOut;
    }

    /**
     * @dev Function to withdraw tokens from the Balancer pool.
     * @param amt Amount of tokens to withdraw.
     */
    function withdraw(uint amt) public {
        // check the balance of user
        if (balances[msg.sender] < amt) {
            revert("Yield::insufficient funds");
        }
        balances[msg.sender] -= amt;
        uint256[] memory minAmountsOut = new uint256[](_tokens.length);

        bool toInternalBalance = false;
        bytes32 _poolId = basepool.getPoolId();

        address sender = address(this);

        bytes memory userdata = abi.encode(
            WeightedPoolUserData.ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT,
            amt
        );

        IVault.ExitPoolRequest memory request = IVault.ExitPoolRequest({
            assets: _convertERC20sToAssets(_tokens),
            minAmountsOut: minAmountsOut,
            userData: userdata,
            toInternalBalance: toInternalBalance
        });
        (, uint[] memory amts) = balancerQ.queryExit(
            _poolId,
            sender,
            sender,
            request
        );

        vault.exitPool(_poolId, sender, payable(sender), request);
        token1.transfer(msg.sender, amts[0]);
        token2.transfer(msg.sender, amts[1]);
    }
}
