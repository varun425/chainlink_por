//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Chainlink, ChainlinkClient} from "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract GetReserve is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    bytes32 private jobId;
    uint256 private fee;

    uint256 public getReserve;

    event RequestMultipleFulfilled(
        bytes32 indexed requestId,
        uint256 reserve    );

        event RequestMultipleFulfilled2(
        uint256 indexed reserve    );


    constructor() ConfirmedOwner(msg.sender) {
        _setChainlinkToken(0x5e8df0a791232cca30850189a8ee29C651F2d1b0);
        _setChainlinkOracle(0xe394741093BcdC4EF14EdffEd394310c3446d8e9);
        jobId = "07358eac2ee34304b764881bae899c4d"; //07358eac-2ee3-4304-b764-881bae899c4d
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    function requestMultipleParameters() public {
        Chainlink.Request memory req = _buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillMultipleParameters.selector
        );
        req._add(
            "url",
            "https://670a-160-202-37-224.ngrok-free.app/" // replace with external adapter url 
        ); 
        req._add("path", "balance"); // josn path 
        req._addInt("times", 100000000000000000000); // if required

        _sendChainlinkRequest(req, fee); // MWR API.
    }

    /**
     * @notice Fulfillment function for multiple parameters in a single request
     * @dev This is called by the oracle. recordChainlinkFulfillment must be used.
     */
    function fulfillMultipleParameters(
        bytes32 requestId,
        bytes32 reserveResponse
    ) public recordChainlinkFulfillment(requestId) {
        emit RequestMultipleFulfilled(
            requestId,
            uint256(reserveResponse)
        );
        getReserve = uint256(reserveResponse);

    }

    function fulfillMultipleParameters2(
        bytes32 reserveResponse
    ) public  {
        emit RequestMultipleFulfilled2(
            uint256(reserveResponse)
        );
        getReserve = uint256(reserveResponse);

    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
