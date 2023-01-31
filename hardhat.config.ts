import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import 'hardhat-gas-reporter';
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.resolve(__dirname, '..', '.env') });

const coinmarketAPIKey = process.env.COINMARKETCAP_API_KEY;

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  gasReporter: {
    currency: 'USD',
    gasPrice: 21,
    enabled: true,
    coinmarketcap: coinmarketAPIKey
  }
};

export default config;
