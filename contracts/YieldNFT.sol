// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ProgrammableTokenTransfers} from "./CCIPSender.sol";

contract ETHGLobalHack is ERC1155, Ownable, ERC1155Burnable {
    ProgrammableTokenTransfers public chainlinkSender;

    // Mapping to keep track of supported ERC20 tokens
    mapping(address => bool) public acceptedTokens;

    // Prices for minting an NFT in different tokens
    mapping(address => uint256) public mintPrices;

    constructor(address payable _chainlinkSender) ERC1155("https://example.com") Ownable() {
        // Initialize accepted tokens
        acceptedTokens[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = true; // USDC
        acceptedTokens[0xdAC17F958D2ee523a2206206994597C13D831ec7] = true; // USDT
        acceptedTokens[0x6B175474E89094C44Da98b954EedeAC495271d0F] = true; // DAI
        acceptedTokens[0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2] = true; // WETH

        // Initialize mint prices
        mintPrices[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = 100 * 10 ** 6; // 100 USDC
        mintPrices[0xdAC17F958D2ee523a2206206994597C13D831ec7] = 100 * 10 ** 6; // 100 USDT
        mintPrices[0x6B175474E89094C44Da98b954EedeAC495271d0F] = 100 * 10 ** 18; // 100 DAI
        mintPrices[0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2] = 1 * 10 ** 18; // 1 WETH

        chainlinkSender = ProgrammableTokenTransfers(_chainlinkSender);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data,
        address tokenAddress,
        uint64 destinationChainSelector,
        address receiver,
        string memory text
    ) public onlyOwner {
        require(acceptedTokens[tokenAddress], "ETHOnlineHack: Unsupported token");
        uint256 tokenAmount = mintPrices[tokenAddress];

        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(msg.sender, address(chainlinkSender), tokenAmount), "ETHOnlineHack: Transfer failed");

        // Ensure that the ChainlinkSender contract has the necessary allowances to spend the tokens.
        token.approve(address(chainlinkSender), tokenAmount);

        // Calling sendMessagePayLINK function from ChainlinkSender contract
        chainlinkSender.sendMessagePayLINK(destinationChainSelector, receiver, text, address(token), amount);

        _mint(account, id, amount, data);
    }

    function setAcceptedToken(address tokenAddress, bool isAccepted) external onlyOwner {
        acceptedTokens[tokenAddress] = isAccepted;
    }

    function setMintPrice(address tokenAddress, uint256 price) external onlyOwner {
        mintPrices[tokenAddress] = price;
    }
}
