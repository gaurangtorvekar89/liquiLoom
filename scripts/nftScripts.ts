import { ethers } from "hardhat";

async function deploy() {
	// Get the deployment account
	const [deployer] = await ethers.getSigners();
	console.log("Deploying contracts with the account:", deployer.address);

	// Get the contract factory
	const ETHGlobalHackFactory = await ethers.getContractFactory("ETHGLobalHack");

	// Deploy the contract, and pass the constructor arguments
	const chainlinkSenderAddress = "0x1234567890abcdef1234567890abcdef12345678"; // replace with actual address
	const contract = await ETHGlobalHackFactory.deploy(chainlinkSenderAddress);

	// Wait for the contract to be deployed
	await contract.deployed();

	console.log("ETHGLobalHack contract deployed to:", contract.address);
}

async function mint() {
	const contract = await ethers.getContractAt("ETHGLobalHack", "0x2CDaEBCDA5C5B0315AB5D205273367A8962fD410");
	const [owner] = await ethers.getSigners();

	const account = owner.address; // The account receiving the minted tokens
	const id = 1; // The token ID
	const amount = 1; // The amount to mint
	const data = ethers.utils.toUtf8Bytes(""); // Any necessary data
	const tokenAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"; // USDC address for example
	const destinationChainSelector = 1; // Assume Ethereum mainnet
	const receiver = owner.address; // Address receiving on the other chain
	const text = "Hello, World!"; // Some text

	const tx = await contract.connect(owner).mint(account, id, amount, data, tokenAddress, destinationChainSelector, receiver, text);

	const receipt = await tx.wait();
	console.log("Mint transaction confirmed:", receipt.transactionHash);
}

async function setStrategy() {
	const contract = await ethers.getContractAt("ETHGLobalHack", "0x2CDaEBCDA5C5B0315AB5D205273367A8962fD410");
	const [owner] = await ethers.getSigners();

	const tokenId = 1;
	const inputAsset = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"; // USDC address for example
	const outputAssets = ["0x6B175474E89094C44Da98b954EedeAC495271d0F"]; // DAI address for example
	const outputAmounts = [10];
	const protocol = 1;
	const onBehalfOf = owner.address;

	const tx = await contract.connect(owner).setStrategy(tokenId, inputAsset, outputAssets, outputAmounts, protocol, onBehalfOf);

	const receipt = await tx.wait();
	console.log("Set strategy transaction confirmed:", receipt.transactionHash);
}

async function main() {
	// await deploy();
	await setStrategy();
	await mint();
}

// Run the deployment script
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});

