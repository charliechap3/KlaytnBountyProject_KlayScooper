const { network } = require("hardhat");
const { verify } = require('../utils/verify');
const { developmentChains } = require("../helper-hardhat-config");
const { ETHERSCAN_APIKEY } = process.env || "";

const deployKlayScooper = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId

    const args = ["0xe0fbB27D0E7F3a397A67a9d4864D4f4DD7cF8cB9"];

    const klayScooper = await deploy("KlayScooper", {
        from: deployer,
        args: args,
        log: true,
        blockConfirmations: network.config.blockConfirmations
    })

    log("Deploying..................................................")
    log("...........................................................")
    log(klayScooper.address);


    if (!developmentChains.includes(network.name) && chainId == 1001 && ETHERSCAN_APIKEY) {
        await verify(klayScooper.address, args);
    }
}

module.exports.default = deployKlayScooper;
