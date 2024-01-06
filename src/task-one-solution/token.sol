// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Token
 * @dev A simple ERC20 token contract representing Balancer Pool Tokens.
 */
contract Token is ERC20 {
    address owner;
    uint8 fee = 1;
    uint8 percentage = 100;

    /**
     * @dev Constructor to initialize the Token contract.
     */
    constructor() ERC20("Balancer Pool Tokens", "BPT") {
        owner = msg.sender;
    }

    /**
     * @dev Function to mint new tokens.
     */
    function mint() public payable {
        _mint(msg.sender, msg.value);
    }

    /**
     * @dev Function to burn a specified amount of tokens.
     * @param amount The amount of tokens to burn.
     */
    function burn(uint amount) public {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Internal function to update token balances and apply a fee.
     * @param from The address from which tokens are transferred.
     * @param to The address to which tokens are transferred.
     * @param value The amount of tokens being transferred.
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        uint256 _fee = value * (fee / percentage);
        uint256 _remainder = value - _fee;
        super._update(from, owner, _fee);
        super._update(from, to, _remainder);
    }

    /**
     * @dev Fallback function to receive Ether.
     */
    receive() external payable {}
}
