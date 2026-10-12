// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RequestWithNote {
    struct PaymentRequest {
        address requester;
        address target;
        address token; // address(0) for native currency (ETH/MATIC/etc.)
        uint256 amount;
        string note;
        uint256 expiryTime;
        bool fulfilled;
        bool cancelled;
    }

    uint256 public requestCounter;
    mapping(uint256 => PaymentRequest) public requests;

    event RequestCreated(
        uint256 indexed requestId,
        address indexed requester,
        address indexed target,
        address token,
        uint256 amount,
        string note,
        uint256 expiryTime
    );

    event RequestFulfilled(
        uint256 indexed requestId,
        address indexed fulfiller,
        uint256 amount
    );

    event RequestCancelled(uint256 indexed requestId);

    /**
     * @notice Create a payment request with a note and expiration in hours
     * @param target The wallet address being requested from
     * @param token The token address (use address(0) for native currency)
     * @param amount The quantity of tokens or native value requested
     * @param note The text note describing the request
     * @param expiryHours Expiration duration in hours from now
     */
    function createRequest(
        address target,
        address token,
        uint256 amount,
        string calldata note,
        uint256 expiryHours
    ) external returns (uint256) {
        require(target != address(0), "Invalid target address");
        require(target != msg.sender, "Cannot request from yourself");
        require(amount > 0, "Amount must be greater than 0");
        require(expiryHours > 0, "Expiry must be at least 1 hour");

        uint256 requestId = requestCounter++;
        uint256 expiryTime = block.timestamp + (expiryHours * 1 hours);

        requests[requestId] = PaymentRequest({
            requester: msg.sender,
            target: target,
            token: token,
            amount: amount,
            note: note,
            expiryTime: expiryTime,
            fulfilled: false,
            cancelled: false
        });

        emit RequestCreated(
            requestId,
            msg.sender,
            target,
            token,
            amount,
            note,
            expiryTime
        );

        return requestId;
    }

    /**
     * @notice Fulfill a pending payment request
     * @param requestId The ID of the request to fulfill
     */
    function fulfillRequest(uint256 requestId) external payable {
        PaymentRequest storage req = requests[requestId];

        require(!req.fulfilled, "Request already fulfilled");
        require(!req.cancelled, "Request was cancelled");
        require(block.timestamp <= req.expiryTime, "Request has expired");
        require(msg.sender == req.target, "Only target wallet can fulfill");

        req.fulfilled = true;

        if (req.token == address(0)) {
            // Handle native currency fulfillment
            require(msg.value == req.amount, "Incorrect native value sent");
            (bool success, ) = payable(req.requester).call{value: msg.value}("");
            require(success, "Native transfer failed");
        } else {
            // Handle ERC-20 token fulfillment
            require(msg.value == 0, "Do not send native currency for token requests");
            bool success = IERC20(req.token).transferFrom(msg.sender, req.requester, req.amount);
            require(success, "Token transfer failed");
        }

        emit RequestFulfilled(requestId, msg.sender, req.amount);
    }

    /**
     * @notice Cancel a payment request created by the requester
     * @param requestId The ID of the request to cancel
     */
    function cancelRequest(uint256 requestId) external {
        PaymentRequest storage req = requests[requestId];
        require(msg.sender == req.requester, "Only requester can cancel");
        require(!req.fulfilled, "Cannot cancel fulfilled request");
        require(!req.cancelled, "Request already cancelled");

        req.cancelled = true;
        emit RequestCancelled(requestId);
    }
}