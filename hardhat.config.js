require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-deploy");


/** @type import('hardhat/config').HardhatUserConfig */

const { KLAYTN_BAOBAB_RPC, PRIVATE_KEY, ETHERSCAN_APIKEY } = process.env || ""

module.exports = {
    solidity: {
        compilers: [
            { version: "0.8.0" },
            { version: "0.8.12" },
            { version: "0.8.19" },
            { version: "0.8.20" }
        ]
    },
    defaultNetwork: "hardhat",
    networks: {
        klaytn: {
            url: KLAYTN_BAOBAB_RPC || "",
            gasPrice: 250000000000,
            accounts: [PRIVATE_KEY],
            chainId: 1001,
            blockConfirmations: 6
        }
    },
    etherscan: {
        apikey: ETHERSCAN_APIKEY,
        customChains: [
            {
                network: "klaytn",
                chainId: 1001,
                urls: {
                    apiURL: "https://api-baobab.klaytnscope.com/api",
                    browserURL: "https://baobab.klaytnscope.com",
                },
            },
        ]
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