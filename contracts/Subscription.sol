// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Subscription is Ownable {
    mapping(address => mapping(address => uint256)) private remainingRuns;
    mapping(address => mapping(address => uint256)) private lastPaid;
    mapping(address => mapping(address => uint256)) private amount;
    address private token;

    constructor(address _token) {
        token = _token;
    }

    modifier eligiblePayment(address _merchant, address _customer) {
        require(remainingRuns[_merchant][_customer] > 0, "No runs remaining");
        require(
            (block.timestamp - lastPaid[_merchant][_customer]) < 30 days,
            "Already run within a month"
        );
        require(remainingRuns[_merchant][_customer] > 0, "No runs remaining");
        _;
    }

    modifier onlyAllowed(address _merchant) {
        require(
            owner() == msg.sender || _merchant == msg.sender,
            "Not allowed user"
        );
        _;
    }

    modifier enoughAllowance(address _merchant, address _customer) {
        require(
            IERC20(token).allowance(_customer, address(this)) >=
                amount[_merchant][_customer],
            "Not enough allowance"
        );
        _;
    }

    function createSubscription(
        address _merchant,
        address _customer,
        uint256 _runs
    ) external onlyOwner {
        remainingRuns[_merchant][_customer] = _runs;
    }

    function runSubscription(address _merchant, address _customer)
        external
        eligiblePayment(_merchant, _customer)
        onlyAllowed(_merchant)
        enoughAllowance(_merchant, _customer)
    {
        bool success = IERC20(token).transferFrom(
            _customer,
            _merchant,
            amount[_merchant][_customer]
        );
        require(success, "Transfer failed");
        lastPaid[_merchant][_customer] = block.timestamp;
        remainingRuns[_merchant][_customer] -= 1;
    }
}
