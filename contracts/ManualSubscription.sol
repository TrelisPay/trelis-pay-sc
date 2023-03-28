// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ManualSubscription is Ownable {
    address public token;
    address public merchant;

    constructor(address _token, address _merchant) {
        token = _token;
        merchant = _merchant;
    }
}
