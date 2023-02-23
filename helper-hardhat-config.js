const { ethers } = require("hardhat")
require("dotenv").config();

const networkConfig = {
    80001: {
        name: "mumbai",       
    },
    5: {
        name: "goerli",
    },
    1: {
        name: "mainnet",
        // other config
    },
}

const persistentTestChains = ["goerli", "mumbai"]
const VERIFICATION_BLOCK_CONFIRMATIONS = 6

module.exports = {
    networkConfig,
    persistentTestChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
}
