// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address owner;
    uint8 fee = 1;
    uint8 percentage = 100;

    constructor() ERC20("Balancer Pool Tokens", "BPT") {
        owner = msg.sender;
    }

    function mint() public payable {
        _mint(msg.sender, msg.value);
    }

    function burn(uint amount) public {
        _burn(msg.sender, amount);
    }

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
}
