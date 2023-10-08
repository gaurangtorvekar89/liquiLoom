import { ethers, network } from "hardhat";

async function main() {
	const [deployer] = await ethers.getSigners();
	console.log("Deploying contracts with the account:", deployer.address);

	// Fetch contract factories
	const YieldExecutor = await ethers.getContractFactory("YieldExecutor");

	// Deploy YieldExecutor contract
	const aaveV3PoolAddress = "0xcC6114B983E4Ed2737E9BD3961c9924e6216c704"; // Polygon Mumbai - Pool-Proxy
	const cometAddress = "0xF09F0369aB0a875254fB565E52226c88f10Bc839"; // Polygon Mumbai Testnet - USDC Base
	const yieldExecutor = await YieldExecutor.deploy(aaveV3PoolAddress, cometAddress);

	console.log("YieldExecutor contract deployed to:", yieldExecutor.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});

