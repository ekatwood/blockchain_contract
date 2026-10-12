// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.ico" // Or standard interface if not using OpenZeppelin directly

contract SendWithNote {
    // Event emitted when native currency (ETH/MATIC/etc.) is sent with a note
    event NativeSentWithNote(
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        string note,
        uint256 timestamp
    );

    // Event emitted when ERC-20 tokens are sent with a note
    event TokenSentWithNote(
        address indexed token,
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        string note,
        uint256 timestamp
    );

    /**
     * @notice Send native blockchain currency (ETH, AVAX, MATIC, etc.) with a note
     * @param recipient The address to receive the funds
     * @param note The message/note attached to the transaction
     */
    function sendNative(address payable recipient, string calldata note) external payable {
        require(msg.value > 0, "Must send greater than 0 value");
        require(recipient != address(0), "Invalid recipient address");

        (bool success, ) = recipient.call{value: msg.value}("");
        require(success, "Native currency transfer failed");

        emit NativeSentWithNote(msg.sender, recipient, msg.value, note, block.timestamp);
    }

    /**
     * @notice Send ERC-20 tokens with a note
     * @param token The address of the ERC-20 token contract
     * @param recipient The address to receive the tokens
     * @param amount The quantity of tokens to transfer
     * @param note The message/note attached to the transaction
     */
    function sendToken(
        address token,
        address recipient,
        uint256 amount,
        string calldata note
    ) external {
        require(amount > 0, "Must send greater than 0 tokens");
        require(recipient != address(0), "Invalid recipient address");

        bool success = IERC20(token).transferFrom(msg.sender, recipient, amount);
        require(success, "Token transfer failed");

        emit TokenSentWithNote(token, msg.sender, recipient, amount, note, block.timestamp);
    }
}