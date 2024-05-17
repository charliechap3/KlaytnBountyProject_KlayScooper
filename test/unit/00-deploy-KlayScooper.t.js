const { deployments, getNamedAccounts, ethers } = require("hardhat")
const { assert, expect } = require("chai");
const { developmentChains } = require("../../helper-hardhat-config");


!developmentChains.includes(network.name) ? describe.skip :
    describe("KlayScooper", async () => {

        let klayScooper;
        let deployer;
        const args = ["0xe0fbB27D0E7F3a397A67a9d4864D4f4DD7cF8cB9"];
        const A = "";
        const B = "";
        const path = [A, B];
        const tokenAddresses = []


        const sendValue = await ethers.utils.parseEthers("1")

        beforeEach(async () => {
            deployer = (await getNamedAccounts()).deployer
            klayScooper = await ethers.getContract("KlayScooper", deployer)
        });

        describe("Deployment", async () => {
            it("sets correct router address", async () => {
                const txresponse = await klayScooper.i_RouterAddress();
                assert.equal(txresponse, args);
            });

            it("sets deployer's address", async () => {
                const tx = await klayScooper.i_owner();
                assert.equal(tx, deployer);
            });
        });

        describe("swapTokensForKlay", async () => {
            it("fails if token addresses doesn't exist", async () => {
                await expect(klayScooper.swapTokensForKlay(tokenAddresses)).to.be.revertedWith("KlayScooper__ZeroLengthArray");
            });
        });

    })