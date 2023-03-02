# Trelis smart contract

Trelis smart contract powers trelis subscription module

## Functions

- `checkSubsription`: This function is used to get the subscription data for a customer. Returns allowanace, last paid timestamp, remaining runs and subscription price
- `checkCustomerEligibility`: This function is used to see if the customer is eligible for a charge
- `createSubscription`: This function is used to create/cancel a customer subscription. Only the contract owner can create a subscription
- `runSubscription`: This function can be used to charge a customer
