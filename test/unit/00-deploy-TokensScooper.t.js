const { deployments, getNamedAccounts, ethers } = require("hardhat")
const { assert, expect } = require("chai");
const { developmentChains } = require("../../helper-hardhat-config");


!developmentChains.includes(network.name) ? describe.skip :
    describe("TokensScooper", async () => {

        let tokensScooper;
        let mockKIP7;
        let deployer;
        let tokenAddresses = [];
        const args = ["0xe0fbB27D0E7F3a397A67a9d4864D4f4DD7cF8cB9", "0xe4f05a66ec68b54a58b17c22107b02e0232cc817"];

        [owner, addr1, addr2] = await ethers.getSigners();

        beforeEach(async () => {
            deployer = (await getNamedAccounts()).deployer;
            await deployments.fixture(["all"]);
            tokensScooper = await ethers.getContract("TokensScooper", deployer);
            mockKIP7 = await ethers.getContract("MOCKKIP7", deployer);
        });

        describe("Deployment", async () => {
            it("sets router address", async () => {
                const txresponse = await tokensScooper.router();
                assert.equal(txresponse, args[0]);
            });

            it("sets router address", async () => {
                const txresponse = await tokensScooper.WKLAY();
                assert.equal(txresponse, args[1]);
            });

            it("sets deployer's address", async () => {
                const tx = await tokensScooper.owner();
                assert.equal(tx, deployer);
            });
        });

        describe("view functions", async () => {
            it("check version", async () => {
                const tx = await tokensScooper.version();
                assert.equal(tx, "1.0.0");
            });

            it("check swapper balance", async () => {
                const bal = await tokensScooper.WKLAY().balanceOf(addr1.address);
                assert.equal(bal, 0);
            });
        });

        describe("swapTokensForKlay", async () => {
            it("reverts if token addresses doesn't exist", async () => {
                const swaptx = tokensScooper.connect(addr1).swapTokensForKlay(tokenAddresses);
                await expect(swaptx).to.be.revertedWith("TokensScooper__ZeroLengthArray");
            });

            it("reverts if token is KIP7 compatible", async () => {
                const swapper = tokensScooper.connect(addr1).swapTokensForKlay(deployer);
                await expect(swapper).to.be.revertedWith("TokensScooper__UnsupportedToken");
            });

            it("reverts if allowance is less than token amount", async () => {
                const tokenAmount = ethers.utils.parseUnits("10", 18);

                tokenAddresses[0] = mockKIP7.address;
                await mockKIP7.mint(addr1.address, tokenAmount);

                const tx = tokensScooper.connect(addr1).swapTokensForKlay(tokenAddresses);
                await expect(tx).to.be.revertedWith("TokensScooper__UnApproved");
            });

            it("reverts insufficient swapper balance", async () => {
                tokenAddresses[0] = mockKIP7.address;

                const bal = await mockKIP7.balanceOf(addr1.address);
                await mockKIP7.connect(addr1).approve(tokensScooper.address, bal);
                const tx = tokensScooper.connect(addr1).swapTokensForKlay(tokenAddresses);
                await expect(tx).to.be.revertedWith("TokensScooper__InsufficientTokensAmount");
            });

            it("Should swap tokens for Klay", async function () {
                tokenAddresses[0] = mockKIP7.address;
                const tokenAmount = ethers.utils.parseUnits("10", 18);

                await mockKIP7.mint(addr1.address, tokenAmount);
                await mockKIP7.connect(addr1).approve(tokensScooper.address, tokenAmount);

                const tx = tokensScooper.connect(addr1).swapTokensForKlay(tokenAddresses);
                await expect(tx)
                    .to.emit(tokensScooper, "TokensSwapped")
                    .withArgs(addr1.address, tokenAmount);
            });
        });

    })