// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {GUILD_AUDIT_CHALLENGE} from "../src/task-two/ctf-challenge/challenge.sol";
import {Solution} from "../src/task-two-solution/challenge_solution.sol";
import {MyProxy} from "../src/task-two-solution/challenge_solution.sol";

contract ChallengeSolutionTest is Test {
    GUILD_AUDIT_CHALLENGE challenge;
    Solution solution;
    MyProxy proxy;

    // @notice to run the test script successfully use this command
    // forge t --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    address origin = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    bytes constant LEVEL_A = (abi.encodePacked("Level A"));
    bytes constant LEVEL_B = (abi.encodePacked("Level B"));
    bytes constant LEVEL_C = (abi.encodePacked("Level C"));
    bytes constant LEVEL_D = (abi.encodePacked("Level D"));

    function setUp() public {
        challenge = new GUILD_AUDIT_CHALLENGE();
        solution = new Solution(challenge);
    }

    function test_solve_challenge_A() public {
        vm.deal(address(solution), 3 ether);
        uint amt = (uint32(uint160(address(solution))) & 0xffff) / 100;
        solution.solve_challenge_A{value: amt}(origin);

        assertTrue(challenge.unlocked(LEVEL_A));
    }

    function test_solve_challenge_B() public {
        test_solve_challenge_A();
        solution.solve_challenge_B();

        assertTrue(challenge.unlocked(LEVEL_B));
    }

    function test_solve_challenge_C() public {
        solution.solve_challenge_C(origin);

        solution.get_C_Profit();

        assertTrue(challenge.unlocked(LEVEL_C));
    }

    function solve_challenge_D() public {
        test_solve_challenge_C();
        proxy = new MyProxy(challenge);
    }

    function test_solve_challenge_D2() public {
        solve_challenge_D();
        proxy.solve_challenge_D2();

        assertTrue(challenge.unlocked(LEVEL_D));
    }
}
