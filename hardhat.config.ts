import "@nomicfoundation/hardhat-toolbox";
const dotenv = require("dotenv");
dotenv.config();

const keys = process.env.PRIVATE_KEY || "";
const scrollUrl = "https://alpha-rpc.scroll.io/l2";

const config = {
	solidity: "0.8.10",
	etherscan: {
		apiKey: {
			polygonMumbai: process.env.MUMBAI_KEY || "",
			scroll: process.env.ETHERSCAN || "",
			arbitrumGoerli: process.env.ARBISCAN || "",
		},
		customChains: [
			{
				network: "scroll",
				chainId: 534353,
				urls: {
					apiURL: "https://blockscout.scroll.io/api",
					browserURL: "https://blockscout.scroll.io",
				},
			},
			{
				network: "arbitrumGoerli",
				chainId: 421613,
				urls: {
					apiURL: "https://api-goerli.arbiscan.io/api",
					browserURL: "https://goerli.arbiscan.io/",
				},
			},

			{
				network: "polygonMumbai",
				chainId: 80001,
				urls: {
					apiURL: "https://api-testnet.polygonscan.com/api",
					browserURL: "https://mumbai.polygonscan.com/",
				},
			},
		],
	},
	networks: {
		scroll: {
			url: scrollUrl,
			accounts: [keys],
		},
		mumbai: {
			allowUnlimitedContractSize: true,
			gas: 2100000,
			gasPrice: 8000000000,
			url: "https://polygon-mumbai.g.alchemy.com/v2/A1HhakaFYuT5oFTaQXweIQKBnWIG4rZq",
			accounts: [keys],
		},

		arbitrumGoerli: {
			url: "https://arbitrum-goerli.blockpi.network/v1/rpc/public",
			accounts: [keys],
		},

		sepolia: {
			url: "https://ethereum-sepolia.publicnode.com", // Replace with the actual RPC URL
			accounts: [keys],
		},
	},
	settings: {
		optimizer: {
			enabled: true,
			runs: 200,
		},
	},
};

export default config;

