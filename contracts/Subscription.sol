// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

abstract contract ReentrancyGuard {
    mapping (address => bool) internal locked;

    modifier noReentrant(address _customer) {
        require(!locked[_customer], "One transaction is already running");
        locked[_customer] = true;
        _;
        locked[_customer] = false;
    }
}

contract Subscription is Ownable, Pausable, ReentrancyGuard {
    enum subscriptionTypeEnum {
        MONTHLY,
        YEARLY
    }

    mapping(address => uint256) private remainingRuns;
    mapping(address => uint256) private lastPaid;
    mapping(address => uint256) private amount;
    mapping(address => subscriptionTypeEnum) subscriptionType;
    address private token;
    address private merchant;

    constructor(address _token, address _merchant) {
        token = _token;
        merchant = _merchant;
    }

    modifier eligiblePayment(address _customer) {
        require(remainingRuns[_customer] > 0, "No runs remaining");
        if (subscriptionType[_customer] == subscriptionTypeEnum.MONTHLY) {
            require(
                (block.timestamp - lastPaid[_customer]) >= 27 days,
                "Already run within a month"
            );
        } else {
            require(
                (block.timestamp - lastPaid[_customer]) >= 364 days,
                "Already run within a year"
            );
        }
        _;
    }

    modifier onlyAllowed() {
        require(
            owner() == msg.sender || merchant == msg.sender,
            "Not allowed user"
        );
        _;
    }

    modifier enoughAllowance(address _customer) {
        require(
            IERC20(token).allowance(_customer, address(this)) >=
                amount[_customer],
            "Not enough allowance"
        );
        _;
    }

    function checkSubscription(address _customer)
        external
        view
        returns (
            uint256 _allowance,
            uint256 _lastPaid,
            uint256 _runs,
            uint256 _subscriptionPrice
        )
    {
        return (
            IERC20(token).allowance(_customer, address(this)),
            lastPaid[_customer],
            remainingRuns[_customer],
            amount[_customer]
        );
    }

    function checkCustomerEligibility(address _customer)
        external
        view
        returns (bool)
    {
        bool isAllowedRuns = remainingRuns[_customer] > 0;
        bool notTimeLocked = true;
        if (subscriptionType[_customer] == subscriptionTypeEnum.MONTHLY) {
            notTimeLocked = (block.timestamp - lastPaid[_customer]) >= 27 days;
        } else {
            notTimeLocked = (block.timestamp - lastPaid[_customer]) >= 364 days;
        }
        bool isEnoughAllowance = IERC20(token).allowance(
            _customer,
            address(this)
        ) >= amount[_customer];

        return isAllowedRuns && notTimeLocked && isEnoughAllowance;
    }

    function createSubscription(
        address _customer,
        uint256 _runs,
        uint256 _amount,
        subscriptionTypeEnum _subscriptionType
    ) external onlyOwner whenNotPaused noReentrant(_customer){
        remainingRuns[_customer] = _runs;
        amount[_customer] = _amount;
        subscriptionType[_customer] = _subscriptionType;
        lastPaid[_customer] = 0;
    }

    function runSubscription(address _customer)
        external
        eligiblePayment(_customer)
        enoughAllowance(_customer)
        noReentrant(_customer)
        onlyAllowed
        whenNotPaused
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
