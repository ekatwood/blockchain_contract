// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MintToken is ERC20 {
    // Metadata fields
    string public logoUri;
    string public description;
    uint8 private immutable _customDecimals;

    // Event emitted upon successful token deployment and minting
    event TokenDeployed(
        address indexed creator,
        address indexed recipient,
        string name,
        string symbol,
        uint256 totalSupply,
        uint8 decimals,
        string logoUri,
        string description
    );

    /**
     * @notice Deploy a custom ERC-20 token with metadata and initial supply
     * @param name_ Token name (e.g., "My Token")
     * @param symbol_ Token symbol (e.g., "MTK")
     * @param initialSupply Raw token amount before decimal scaling
     * @param decimals_ Number of decimals (typically 18)
     * @param _logoUri URL pointing to the token's logo image
     * @param _description Optional description of the token project
     * @param recipient Address to receive the initial minted supply
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        uint8 decimals_,
        string memory _logoUri,
        string memory _description,
        address recipient
    ) ERC20(name_, symbol_) {
        require(bytes(name_).length > 0, "Name cannot be empty");
        require(bytes(symbol_).length > 0, "Symbol cannot be empty");
        require(initialSupply > 0, "Initial supply must be greater than 0");

        _customDecimals = decimals_;
        logoUri = _logoUri;
        description = _description;

        // Determine mint recipient (default to deployer if address(0) is passed)
        address mintRecipient = recipient == address(0) ? msg.sender : recipient;

        // Mint initial supply scaled by decimals
        _mint(mintRecipient, initialSupply * (10 ** decimals_));

        emit TokenDeployed(
            msg.sender,
            mintRecipient,
            name_,
            symbol_,
            initialSupply,
            decimals_,
            _logoUri,
            _description
        );
    }

    /**
     * @notice Returns the custom decimals configured for this token
     */
    function decimals() public view virtual override returns (uint8) {
        return _customDecimals;
    }
}