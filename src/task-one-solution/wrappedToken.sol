// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WrapperToken is ERC20 {
    IERC20 tokenIn;

    constructor(address _tokenIn) ERC20("Wrapped Token", "WToken") {
        tokenIn = IERC20(_tokenIn);
    }

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

    function withdraw(uint amount) external {
        _burn(msg.sender, amount);
        tokenIn.transfer(msg.sender, amount);
    }
}
