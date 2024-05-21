const { network } = require("hardhat");
const { verify } = require('../utils/verify');
const { developmentChains } = require("../helper-hardhat-config");
const { ETHERSCAN_APIKEY } = process.env || "";

const deployTokensScooper = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    WKLAY = "0xe4f05a66ec68b54a58b17c22107b02e0232cc817";
    ROUTER = "0xe0fbB27D0E7F3a397A67a9d4864D4f4DD7cF8cB9";

    const args = [WKLAY, ROUTER];

    const tokensScooper = await deploy("TokensScooper", {
        from: deployer,
        args: args,
        log: true,
        blockConfirmations: network.config.blockConfirmations
    });

    log("Deploying..................................................")
    log("...........................................................")
    log(tokensScooper.address);

    if (!developmentChains.includes(network.name) && chainId == 1001 && ETHERSCAN_APIKEY) {
        await verify(tokensScooper.address, args);
    }
}

module.exports.default = deployTokensScooper;
module.exports.tags = ["all", "tokensScooper"];


// a7e16cc8ea9740ca92dd01a34ab691120e4b0f9e74a3bf18d7273a0d860a6002 pk
// a7e16cc8ea9740ca92dd01a34ab691120e4b0f9e74a3bf18d7273a0d860a6002 fpk

// 0xe4f05a66ec68b54a58b17c22107b02e0232cc817 to

// 0x5664eeeE3C63431eF1981f2bDBaB2690ee33f1e8 fpa