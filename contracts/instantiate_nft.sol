// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SingleNFTWithRoyalty is ERC721, ERC2981, Ownable {
    string private _customTokenURI;
    uint256 public constant TOKEN_ID = 1;

    event SingleNFTDeployed(
        address indexed creator,
        string name,
        string symbol,
        string tokenURI,
        address royaltyReceiver,
        uint96 feeNumerator
    );

    /**
     * @notice Deploy a single 1-of-1 NFT with optional royalties
     * @param name_ Artwork or item name
     * @param symbol_ Token symbol
     * @param tokenURI_ Direct metadata URI for this specific piece (e.g., ipfs://...)
     * @param royaltyReceiver Address to receive secondary sale royalties (address(0) for none)
     * @param feeNumerator Royalty fee in basis points (e.g., 500 = 5%, 250 = 2.5%)
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory tokenURI_,
        address royaltyReceiver,
        uint96 feeNumerator
    ) ERC721(name_, symbol_) Ownable(msg.sender) {
        require(bytes(name_).length > 0, "Name cannot be empty");
        require(bytes(symbol_).length > 0, "Symbol cannot be empty");
        require(bytes(tokenURI_).length > 0, "Token URI cannot be empty");

        _customTokenURI = tokenURI_;

        // Set up EIP-2981 royalties if a receiver and fee are specified
        if (royaltyReceiver != address(0) && feeNumerator > 0) {
            _setDefaultRoyalty(royaltyReceiver, feeNumerator);
        }

        // Automatically mint the single 1-of-1 token to the deployer
        _safeMint(msg.sender, TOKEN_ID);

        emit SingleNFTDeployed(
            msg.sender,
            name_,
            symbol_,
            tokenURI_,
            royaltyReceiver,
            feeNumerator
        );
    }

    /**
     * @notice Returns the metadata URI for the single token
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(tokenId == TOKEN_ID, "Token does not exist");
        return _customTokenURI;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}