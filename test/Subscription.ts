import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Subscription", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearSubscriptionFixture() {
 

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Subscription = await ethers.getContractFactory("Subscription");
    const subscription = await Subscription.deploy(owner.address, owner.address);

    return { subscription, owner, otherAccount };
  }

describe("Test Suite", function () {
    it("Run subscription once", async function () {
      const { subscription, otherAccount } = await loadFixture(deployOneYearSubscriptionFixture);
      let tx = await subscription.createSubscription(otherAccount.address, 11, 11, 1);
      await tx.wait();
    });
    it("Run subscription once", async function () {
      const { subscription, otherAccount } = await loadFixture(deployOneYearSubscriptionFixture);
      let tx = await subscription.createSubscription(otherAccount.address, 11, 11, 1);
      await tx.wait();
      tx = await subscription.createSubscription(otherAccount.address, 11, 11, 1);
      await tx.wait();
    });

});


// describe("Events", function () {
//       it("Should emit an event on withdrawals", async function () {
//         const { subscription } = await loadFixture(
//           deployOneYearSubscriptionFixture
//         );

//         await time.increaseTo(unsubscriptionTime);

//         await expect(subscription.withdraw())
//           .to.emit(subscription, "CustomEvent")
//           .withArgs(subscriptionedAmount, anyValue); // We accept any value as `when` arg
//       });
// });


});