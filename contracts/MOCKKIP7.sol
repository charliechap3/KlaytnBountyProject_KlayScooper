// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@klaytn/contracts/KIP/token/KIP7/KIP7.sol";

contract MOCKKIP7 is KIP7 {
    constructor() KIP7("Mock KIP7 Token", "MK7") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}