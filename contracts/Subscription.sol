// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Subscription is Ownable, Pausable {
    mapping(address => uint256) private remainingRuns;
    mapping(address => uint256) private lastPaid;
    mapping(address => uint256) private amount;
    address private token;
    address private merchant;

    constructor(address _token, address _merchant) {
        token = _token;
        merchant = _merchant;
    }

    modifier eligiblePayment(address _customer) {
        require(remainingRuns[_customer] > 0, "No runs remaining");
        require(
            (block.timestamp - lastPaid[_customer]) < 28 days,
            "Already run within a month"
        );
        require(remainingRuns[_customer] > 0, "No runs remaining");
        _;
    }

    modifier onlyAllowed {
        require(
            owner() == msg.sender || merchant == msg.sender,
            "Not allowed user"
        );
        _;
    }

    modifier enoughAllowance( address _customer) {
        require(
            IERC20(token).allowance(_customer, address(this)) >=
                amount[_customer],
            "Not enough allowance"
        );
        _;
    }

    function createSubscription(
        address _customer,
        uint256 _runs
    ) external onlyOwner {
        remainingRuns[_customer] = _runs;
    }

    function runSubscription(address _customer)
        external
        eligiblePayment(_customer)
        onlyAllowed
        enoughAllowance(_customer)
    {
        bool success = IERC20(token).transferFrom(
            _customer,
            merchant,
            amount[_customer]
        );
        require(success, "Transfer failed");
        lastPaid[_customer] = block.timestamp;
        remainingRuns[_customer] -= 1;
    }
}
