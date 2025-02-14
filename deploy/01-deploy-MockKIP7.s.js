const { network } = require("hardhat");
const { verify } = require('../utils/verify');
const { developmentChains } = require("../helper-hardhat-config");
const { ETHERSCAN_APIKEY } = process.env || "";

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    let args = [];

    if (developmentChains.includes(network.name)) {
        log("Local Network detected, deploying Mock..")

        const mockkip7 = await deploy("MOCKKIP7", {
            from: deployer,
            args: args,
            log: true,
            blockConfirmations: network.config.blockConfirmations
        });

        log("Mocks deployed...!")
        log(mockkip7.address)
        log("............................................................................")

    } else if (!developmentChains.includes(network.name) && chainId == 1001 && ETHERSCAN_APIKEY) {
        await verify(mockkip7.address, args);
    } else {
        return;
    }
}

module.exports.tags = ["all", "mocks"]
