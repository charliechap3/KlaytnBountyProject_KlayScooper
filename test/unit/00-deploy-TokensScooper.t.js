const { deployments, getNamedAccounts, ethers } = require("hardhat")
const { assert, expect } = require("chai");
const { developmentChains } = require("../../helper-hardhat-config");


!developmentChains.includes(network.name) ? describe.skip :
    describe("TokensScooper", async () => {

        let tokensScooper;
        let mockKIP7;
        let deployer;
        const args = ["0xe0fbB27D0E7F3a397A67a9d4864D4f4DD7cF8cB9"];
        [owner, addr1, addr2] = await ethers.getSigners();

        beforeEach(async () => {
            deployer = (await getNamedAccounts()).deployer;
            await deployments.fixture(["all"]);
            tokensScooper = await ethers.getContract("TokensScooper", deployer);
            mockKIP7 = await ethers.getContract("MOCKKIP7", deployer);
        });

        describe("Deployment", async () => {
            it("sets router address", async () => {
                const txresponse = await tokensScooper.i_RouterAddress();
                assert.equal(txresponse, args);
            });

            it("sets deployer's address", async () => {
                const tx = await tokensScooper.i_owner();
                assert.equal(tx, deployer);
            });
        });

        describe("view functions", async () => {
            it("checks version", async () => {
                const tx = await tokensScooper.version();
                assert.equal(tx, "1.0.0");
            });

            it("checks klay withdraw threshold", async () => {
                const tx = await tokensScooper.klayThreshold();
                assert.equal(tx, "1");
            });

            it("expects revert swapper balance", async () => {
                const tx = await tokensScooper.swapperBalance()
            })
        });

        describe("swapTokensForKlay", async () => {
            it("fails if token addresses doesn't exist", async () => {
                const swaptx = tokensScooper.swapTokensForKlay(tokenAddresses);
                await expect(swaptx).to.be.revertedWith("TokensScooper__ZeroLengthArray");
            });

            it("reverts if token is KIP7 compatible", async () => {
                const swapper = tokensScooper.swapTokensForKlay(deployer);
                await expect(swapper).to.be.revertedWith("TokensScooper__UnsupportedToken");
            });

            it("reverts if allowance is less than token amount", async () => {
                const tokenAmount = ethers.utils.parseUnits("10", 18);

                await mockKIP7.mint(addr1.address, tokenAmount);
                await expect(tokensScooper.connect(addr1).swapTokensForKlay([mockKIP7.address]))
                    .to.be.revertedWith("TokensScooper__InsufficientAllowance");
            })
        });

    })