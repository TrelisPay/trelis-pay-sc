// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


contract Subscription is Ownable, Pausable {
    enum SubscriptionTypeEnum {
        MONTHLY,
        YEARLY
    }
    
    address public token;
    address public merchant;

    struct Subscription {
        uint96 remainingRuns;
        uint96 lastPaid;
        uint96 amount;
        SubscriptionTypeEnum subscriptionType;
    }

    mapping(address => Subscription) public subscriptions;

    constructor(address _token, address _merchant) {
        token = _token;
        merchant = _merchant;
    }

    modifier onlyAllowed() {
        require(
            owner() == msg.sender || merchant == msg.sender,
            "Not allowed user"
        );
        _;
    }

    function checkSubscription(address _customer)
        external
        view
        returns (
            uint256 _allowance,
            uint96 _lastPaid,
            uint96 _runs,
            uint256 _subscriptionPrice
        )
    {
        Subscription memory subscription = subscriptions[_customer];
        return (
            IERC20(token).allowance(_customer, address(this)),
            subscription.lastPaid,
            subscription.remainingRuns,
            subscription.amount 
        );
    }

    function createSubscription(
        address _customer,
        uint96 _runs,
        uint96 _amount,
        SubscriptionTypeEnum _subscriptionType
    ) external onlyOwner whenNotPaused {
        Subscription memory subscription = Subscription({
            remainingRuns:_runs,
            lastPaid: uint96(block.timestamp),
            amount: _amount,
            subscriptionType: _subscriptionType
        });
        subscriptions[_customer] = subscription;
    }

    function runSubscription(address _customer)
        external
        onlyAllowed
        whenNotPaused
    {
        Subscription memory subscription = subscriptions[_customer];
        
        // Checks
        require(subscription.remainingRuns > 0, "No runs remaining");
        if (subscription.subscriptionType == SubscriptionTypeEnum.MONTHLY) {
            require(
                (block.timestamp - subscription.lastPaid) >= 27 days,
                "Already run within a month"
            );
        } else {
            require(
                (block.timestamp - subscription.lastPaid) >= 364 days,
                "Already run within a year"
            );
        }

        // Effects
        subscription.lastPaid = uint96(block.timestamp);
        subscription.remainingRuns -= 1;

        // Update subscription state
        subscriptions[_customer] = subscription;

        // Interactions
        bool success = IERC20(token).transferFrom(
            _customer,
            merchant,
            uint256(subscription.amount)
        );
        require(success, "Transfer failed");
    }
}
