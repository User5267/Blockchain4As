const { expect } = require("chai");

describe("StakingSmartContract", function () {
  let owner;
  let user1;
  let user2;
  let contract;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("0xad13628d37f87A3e3157cB2449e14A83E0158f55"); // Replace 'YourContract' with your actual contract name
    contract = await Contract.deploy(100000); // Deploy your contract with an initial supply
    await contract.deployed();
  });

  it("should allow users to stake and receive rewards", async function () {
    const initialBalance = await contract.balanceOf(user1.address);
    expect(initialBalance).to.equal(100000);

    await contract.connect(user1).stake(1000);

    const stakedBalance = await contract.stakedBalance(user1.address);
    expect(stakedBalance).to.equal(1000);

    // Fast-forward time by 31 seconds to trigger rewards
    await network.provider.send("evm_increaseTime", [31]);

    await contract.connect(owner).reward();

    const userRewards = await contract.rewards(user1.address);
    expect(userRewards).to.equal(50); // 1000 * 5% = 50

    await contract.connect(user1).unstake();

    const finalBalance = await contract.balanceOf(user1.address);
    expect(finalBalance).to.equal(100050); // Initial balance + rewards

    const finalStakedBalance = await contract.stakedBalance(user1.address);
    expect(finalStakedBalance).to.equal(0);
  });

  it("should not allow users to stake without sufficient funds", async function () {
    await expect(contract.connect(user1).stake(100001)).to.be.revertedWith("Insufficient funds");
  });

  it("should not allow users to unstake before the staking duration", async function () {
    await contract.connect(user1).stake(1000);

    await expect(contract.connect(user1).unstake()).to.be.revertedWith("The duration of the steak is not fulfilled");
  });
});
