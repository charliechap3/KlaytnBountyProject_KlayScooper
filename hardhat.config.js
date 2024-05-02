require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-deploy");


/** @type import('hardhat/config').HardhatUserConfig */

const { SEPOLIA_RPC, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env || ""

module.exports = {
    solidity: {
        compilers: [
            { version: "0.8.22" },
            { version: "0.6.6" }
        ]
    },
    defaultNetwork: "hardhat",
    networks: {
        sepolia: {
            url: SEPOLIA_RPC || "",
            accounts: [PRIVATE_KEY],
            chainId: 11155111,
            blockConfirmations: 6
        }
    },
    etherscan: {
        apikey: ETHERSCAN_API_KEY,
    },
    sourcify: {
        enabled: true,
    },
    gasReporter: {
        enabled: true,
        outputFile: "gas-report.txt",
        noColors: true
    },
    namedAccounts: {
        deployer: {
            default: 0
        }
    }

};