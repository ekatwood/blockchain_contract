// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SetPriceSwap is ReentrancyGuard {
    struct SwapOffer {
        address creator;
        address target;       // address(0) for ambiguous/public swap, or a specific wallet address
        address tokenIn;      // Token provided by the creator (locked in escrow)
        uint256 amountIn;
        address tokenOut;     // Token requested in return
        uint256 amountOut;
        uint256 expiryTime;
        bool completed;
        bool cancelled;
    }

    uint256 public offerCounter;
    mapping(uint256 => SwapOffer) public offers;

    event SwapCreated(
        uint256 indexed offerId,
        address indexed creator,
        address indexed target,
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 amountOut,
        uint256 expiryTime
    );

    event SwapCompleted(
        uint256 indexed offerId,
        address indexed filler
    );

    event SwapCancelled(uint256 indexed offerId);

    /**
     * @notice Create a token swap offer (targeted or ambiguous/public)
     * @param target Specific wallet address allowed to fill, or address(0) for an open public offer
     * @param tokenIn Address of the token you are offering
     * @param amountIn Amount of tokenIn you are locking in escrow
     * @param tokenOut Address of the token you want in return
     * @param amountOut Amount of tokenOut you expect
     * @param expiryHours Expiration duration in hours from now
     */
    function createSwapOffer(
        address target,
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 amountOut,
        uint256 expiryHours
    ) external nonReentrant returns (uint256) {
        require(amountIn > 0, "Amount in must be greater than 0");
        require(amountOut > 0, "Amount out must be greater than 0");
        require(tokenIn != address(0) && tokenOut != address(0), "Invalid token addresses");
        require(expiryHours > 0, "Expiry must be at least 1 hour");

        // Transfer tokenIn from creator to this contract (Escrow)
        bool success = IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        require(success, "TokenIn escrow transfer failed");

        uint256 offerId = offerCounter++;
        uint256 expiryTime = block.timestamp + (expiryHours * 1 hours);

        offers[offerId] = SwapOffer({
            creator: msg.sender,
            target: target,
            tokenIn: tokenIn,
            amountIn: amountIn,
            tokenOut: tokenOut,
            amountOut: amountOut,
            expiryTime: expiryTime,
            completed: false,
            cancelled: false
        });

        emit SwapCreated(
            offerId,
            msg.sender,
            target,
            tokenIn,
            amountIn,
            tokenOut,
            amountOut,
            expiryTime
        );

        return offerId;
    }

    /**
     * @notice Fill an active swap offer
     * @param offerId The ID of the swap offer to fill
     */
    function fillSwap(uint256 offerId) external nonReentrant {
        SwapOffer storage offer = offers[offerId];

        require(!offer.completed, "Swap already completed");
        require(!offer.cancelled, "Swap was cancelled");
        require(block.timestamp <= offer.expiryTime, "Swap offer has expired");

        // If a target is specified, enforce that only that wallet can fill it.
        // If target is address(0), any wallet can sign and fill it (first-come, first-served).
        if (offer.target != address(0)) {
            require(msg.sender == offer.target, "Only the specified target wallet can fill this swap");
        }

        offer.completed = true;

        // 1. Transfer tokenOut from the filler to the swap creator
        bool successOut = IERC20(offer.tokenOut).transferFrom(msg.sender, offer.creator, offer.amountOut);
        require(successOut, "TokenOut transfer to creator failed");

        // 2. Transfer escrowed tokenIn from the contract to the filler
        bool successIn = IERC20(offer.tokenIn).transfer(msg.sender, offer.amountIn);
        require(successIn, "TokenIn transfer to filler failed");

        emit SwapCompleted(offerId, msg.sender);
    }

    /**
     * @notice Cancel an active swap offer and reclaim escrowed tokens (creator only)
     * @param offerId The ID of the swap offer to cancel
     */
    function cancelSwap(uint256 offerId) external nonReentrant {
        SwapOffer storage offer = offers[offerId];
        require(msg.sender == offer.creator, "Only creator can cancel");
        require(!offer.completed, "Cannot cancel completed swap");
        require(!offer.cancelled, "Swap already cancelled");

        offer.cancelled = true;

        // Return escrowed tokenIn to creator
        bool success = IERC20(offer.tokenIn).transfer(offer.creator, offer.amountIn);
        require(success, "Refund transfer failed");

        emit SwapCancelled(offerId);
    }
}