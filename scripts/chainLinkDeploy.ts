import { ethers, network } from "hardhat";

async function main(): Promise<void> {
	const chainId = network.name; // Use network.name to get the chain name

	const routerAddress = getRouterAddress(chainId);
	const linkTokenAddress = getLinkTokenAddress(chainId);

	const ProgrammableTokenTransfers = await ethers.getContractFactory("ProgrammableTokenTransfers");
	const programmableTokenTransfers = await ProgrammableTokenTransfers.deploy(routerAddress, linkTokenAddress);
	await programmableTokenTransfers.deployed();

	console.log("Contract deployed to:", programmableTokenTransfers.address);
}

function getRouterAddress(chainId: string): string {
	const routers: any = {
		sepolia: "0xD0daae2231E9CB96b94C8512223533293C3693Bf",
		mumbai: "0x70499c328e1E2a3c41108bd3730F6670a44595D1",
	};
	return routers[chainId];
}

function getLinkTokenAddress(chainId: string): string {
	const linkTokens: any = {
		sepolia: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
		mumbai: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
	};
	return linkTokens[chainId];
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});

