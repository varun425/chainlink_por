// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

contract GoldVaultChecker is ChainlinkClient, KeeperCompatibleInterface {
    using Chainlink for Chainlink.Request;

    uint256 public goldValue;
    uint256 public lastTimestamp;
    uint256 public interval;
    uint256 private fee;
    address private oracle;
    bytes32 private jobId;
    bool public goldPresent;

    event GoldDataUpdated(bool goldPresent, uint256 goldValue);

    constructor(uint256 _interval) {
        interval = _interval;
        lastTimestamp = block.timestamp;
        _setChainlinkToken(0x5e8df0a791232cca30850189a8ee29C651F2d1b0);
        _setChainlinkOracle(0xe394741093BcdC4EF14EdffEd394310c3446d8e9);
        jobId = "b1d42cd54a3a4200b1f725a68e48aad8"; //bc328463-1e16-4f69-be1f-1aab6ac66de2
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    function checkUpkeep(
        bytes calldata checkData
    ) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp - lastTimestamp) > interval;
        performData = checkData;
    }

    function performUpkeep(
        bytes calldata  performData
    ) external override {
        if ((block.timestamp - lastTimestamp) > interval) {
            lastTimestamp = block.timestamp;
            requestGoldData();
            performData;
        }
    }

    function requestGoldData() private {
        Chainlink.Request memory req = _buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );
        req._add("url", "https://c169-160-202-37-240.ngrok-free.app/");
        req._add("path", "balance");
        req._addInt("times", 100000000000000000000);
        _sendChainlinkRequestTo(oracle, req, fee);
    }

    function fulfill(
        bytes32 _requestId,
        bool _goldPresent,
        uint256 _goldValue
    ) public recordChainlinkFulfillment(_requestId) {
        emit GoldDataUpdated(_goldPresent, _goldValue);
        goldPresent = _goldPresent;
        goldValue = _goldValue;
    }
}
