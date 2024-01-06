// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title WrapperToken
 * @dev A contract that wraps an existing ERC20 token, allowing users to deposit and withdraw the underlying token.
 */
contract WrapperToken is ERC20 {
    IERC20 tokenIn;

    /**
     * @dev Constructor to initialize the WrapperToken.
     * @param _tokenIn Address of the underlying ERC20 token to be wrapped.
     */
    constructor(address _tokenIn) ERC20("Wrapped Token", "WToken") {
        tokenIn = IERC20(_tokenIn);
    }

    /**
     * @dev Function to deposit the underlying token and mint wrapped tokens.
     * @param amount Amount of the underlying token to deposit.
     * @param _to Address to receive the minted wrapped tokens.
     * @return amounntToMint The amount of wrapped tokens minted.
     */
    function deposit(
        uint amount,
        address _to
    ) external returns (uint amounntToMint) {
        uint balanceBeforeTransfer = tokenIn.balanceOf(address(this));
        tokenIn.transferFrom(_to, address(this), amount);
        uint balanceAfterTransfer = tokenIn.balanceOf(address(this));

        amounntToMint = balanceAfterTransfer - balanceBeforeTransfer;
        _mint(msg.sender, amounntToMint);
    }

    /**
     * @dev Function to withdraw wrapped tokens and redeem the underlying token.
     * @param amount Amount of wrapped tokens to burn and redeem.
     */
    function withdraw(uint amount) external {
        _burn(msg.sender, amount);
        tokenIn.transfer(msg.sender, amount);
    }
}
