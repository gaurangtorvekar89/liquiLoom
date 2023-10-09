// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ProgrammableTokenTransfers} from "./ChainlinkCCIPSender.sol";
import "../utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ETHGLobalHack is ERC1155, Ownable, ERC1155Burnable {
    using Strings for uint256;

    ProgrammableTokenTransfers public chainlinkSender;

    // Mapping to keep track of supported ERC20 tokens
    mapping(address => bool) public acceptedTokens;

    // Prices for minting an NFT in different tokens
    mapping(address => uint256) public mintPrices;

    struct Strategy {
        address inputAsset;
        address[] outputAssets;
        uint256[] outputAmounts;
        uint8 protocol; // 0 - AaveV3, 1 - CompoundV3
        address onBehalfOf;
    }

    mapping(uint256 => Strategy) public strategies; // tokenId => Strategy

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
        // require(token.transferFrom(msg.sender, address(chainlinkSender), tokenAmount), "ETHOnlineHack: Transfer failed");

        // Ensure that the ChainlinkSender contract has the necessary allowances to spend the tokens.
        // token.approve(address(chainlinkSender), tokenAmount);

        // Calling sendMessagePayLINK function from ChainlinkSender contract
        // chainlinkSender.sendMessagePayLINK(destinationChainSelector, receiver, text, address(token), amount);

        _mint(account, id, amount, data);
    }

    function setAcceptedToken(address tokenAddress, bool isAccepted) external onlyOwner {
        acceptedTokens[tokenAddress] = isAccepted;
    }

    function setMintPrice(address tokenAddress, uint256 price) external onlyOwner {
        mintPrices[tokenAddress] = price;
    }

    function constructAttributes(uint256 tokenId) internal view returns (string memory attributes) {
        Strategy memory strategy = strategies[tokenId];

        attributes = string(
            abi.encodePacked(
                '[{"trait_type":"Protocol","value":"',
                strategy.protocol == 0 ? "AaveV3" : "CompoundV3",
                '"},',
                '{"trait_type":"Input Asset","value":"',
                strategy.inputAsset,
                '"},',
                '{"trait_type":"Output Asset 1","value":"',
                strategy.outputAssets[0],
                '"},',
                '{"trait_type":"Output Amount 1","value":"',
                strategy.outputAmounts[0].toString(),
                '"},'
            )
        );
    }

    //Finds an image for the player based on the player class
    function findImageBasedOnTokenId(uint256 tokenId) internal pure returns (string memory) {
        string memory image;

        if (tokenId == 0) {
            image = "https://gateway.ipfs.io/1";
        } else if (tokenId == 1) {
            image = "https://gateway.ipfs.io/2";
        } else if (tokenId == 2) {
            image = "https://gateway.ipfs.io/3";
        } else if (tokenId == 3) {
            image = "https://gateway.ipfs.io/4";
        } else if (tokenId == 4) {
            image = "https://gateway.ipfs.io/5";
        } else if (tokenId == 5) {
            image = "https://gateway.ipfs.io/6";
        } else if (tokenId == 6) {
            image = "https://gateway.ipfs.io/7";
        }

        return image;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    // Bypass for a `--via-ir` bug (https://github.com/chiru-labs/ERC721A/pull/364).
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        string memory attributes = constructAttributes(tokenId);
        string memory base = "data:application/json;base64,";
        string memory image = findImageBasedOnTokenId(tokenId);

        string memory baseName = "Yield NFT";
        string memory fullName = string(abi.encodePacked(baseName, tokenId.toString()));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked('{"name":', fullName, '", "attributes":', attributes, ', "image":"', image, '"}')
                )
            )
        );

        return string(abi.encodePacked(base, json));
    }

    function setStrategy(
        uint256 tokenId,
        address inputAsset,
        address[] memory outputAssets,
        uint256[] memory outputAmounts,
        uint8 protocol,
        address onBehalfOf
    ) external onlyOwner {
        strategies[tokenId] = Strategy(inputAsset, outputAssets, outputAmounts, protocol, onBehalfOf);
    }
}
