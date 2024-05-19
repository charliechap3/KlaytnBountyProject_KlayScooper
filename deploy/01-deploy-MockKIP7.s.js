const { network } = require("hardhat");
const { verify } = require('../utils/verify');
const { developmentChains } = require("../helper-hardhat-config");
const { ETHERSCAN_APIKEY } = process.env || "";

const deployMockKIP7 = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    const mockkip7 = await deploy("MOCKKIP7", {
        from: deployer,
        args: args,
        log: true,
        blockConfirmations: network.config.blockConfirmations
    })

    log("Deploying..................................................")
    log("...........................................................")
    log(mockkip7.address);


    if (!developmentChains.includes(network.name) && chainId == 1001 && ETHERSCAN_APIKEY) {
        await verify(mockkip7.address, args);
    }
}

module.exports.tags = ["all", "mocks"]
