const path = require("path");
const fs = require("fs");
const { ethers } = require("hardhat");
import { poolAbi } from "../utils/abis/aavePool";
import { aaveWrappedTokenGatewayAbi } from "../utils/abis/aaveWrappedTokenGateway";
import { aaveContracts } from "../utils/aaveContractAddresses";
import { compoundV3Comet } from "../utils/abis/compoundV3Abi";
const hre = require("hardhat");

const dotenv = require("dotenv");
dotenv.config();

async function main() {
	const networkName = process.env.HARDHAT_NETWORK;
	console.log("Network name: ", networkName);
	const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL1);
	const deployer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
	console.log("Deployer address: ", deployer.address);

	const aavePool = new ethers.Contract(aaveContracts.PolygonMumbai.Pool, poolAbi, deployer);
	const cometCompoundV3 = new ethers.Contract("0xF09F0369aB0a875254fB565E52226c88f10Bc839", compoundV3Comet, deployer);
	// Load the contract artifacts
	const contractArtifacts = await hre.artifacts.readArtifact("YieldExecutor");

	// The ABI is now available as a JavaScript object
	const abi = contractArtifacts.abi;
	const yieldExecutor = new ethers.Contract("0xe937e418Ca1FA013EA37eF42682e0D8E4324e2C0", abi, deployer);

	// This is Mumbai USDC on Aave v3
	const usdcAddress = "0x52D800ca262522580CeBAD275395ca6e7598C014";
	const usdcAmount = ethers.utils.parseUnits("0.001", 6);

	// This is the Mumbai DAI on Compound v3
	const daiAddress = "0x4DAFE12E1293D889221B1980672FE260Ac9dDd28";
	const daiAmount = ethers.utils.parseUnits("0.001", 18);
	console.log("Dai Amount = ", daiAmount.toNumber());

	const strategyAave = {
		assets: [usdcAddress],
		amounts: [usdcAmount],
		onBehalfOf: deployer.address,
	};

	const strategyCompound = {
		assets: [daiAddress],
		amounts: [daiAmount],
		onBehalfOf: deployer.address,
	};

	const overrides = {
		gasLimit: ethers.utils.parseUnits("500000", "wei"), // Example gas limit
		gasPrice: ethers.utils.parseUnits("30", "gwei"), // Example gas price
	};

	const erc20Abi = ["function approve(address spender, uint256 amount) external returns (bool)", "function transfer(address recipient, uint256 amount) external returns (bool)"];

	const usdcContract = new ethers.Contract(usdcAddress, erc20Abi, deployer);
	const approvalTx = await usdcContract.approve(aavePool.address, usdcAmount);

	const approvalReceipt = await approvalTx.wait();
	console.log("Approval transaction was mined in block", approvalReceipt.blockNumber);

	// // Call the supplyAaveV3 function
	// const tx = await yieldExecutor.supplyAaveV3(strategyAave, overrides);
	// // Wait for the transaction to be mined
	// const receipt = await tx.wait();
	// // Log the transaction receipt
	// console.log(receipt);

	// Transfer some DAI to the YieldExecutor contract
	const daiContract = new ethers.Contract(daiAddress, erc20Abi, deployer);
	// Approve DAI to the compound contract
	const transferTx = await daiContract.transfer(yieldExecutor.address, daiAmount);

	const tx = await yieldExecutor.supplyCompoundV3(strategyCompound, overrides);
	const receipt = await tx.wait();
	console.log(receipt.transactionHash);
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});

