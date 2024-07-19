// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Chainlink, ChainlinkClient} from "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract GetReserve is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    int256 public times;
    bytes32 private jobId;
    uint256 private fee;
    uint256 public reserve;
    string public url;
    string public path;
    address private authorizedSender;

    event RequestMultipleFulfilled(bytes32 indexed requestId, uint256 reserve);
    event NewAuthorizedSender(address indexed authorizedSender);
    event JobIdUpdated(bytes32 jobId);
    event UrlUpdated(string url);
    event PathUpdated(string path);
    event TimesUpdated(int256 times);

    modifier onlyAuthorizedSender() {
        require(
            msg.sender == authorizedSender,
            "Should be called by authorized sender"
        );
        _;
    }

    modifier onlyOwnerOrAuthorized() {
        require(
            msg.sender == owner() || msg.sender == authorizedSender,
            "Should be called by owner or authorized sender"
        );
        _;
    }

    constructor(
        address chainlinkToken,
        address chainlinkOracle,
        string memory _jobId,
        uint256 LINK_DIVISIBILITY,
        string memory _url,
        string memory _path,
        int256 _times
    ) ConfirmedOwner(msg.sender) {
        _setChainlinkToken(chainlinkToken);
        _setChainlinkOracle(chainlinkOracle);
        jobId = stringToBytes32(_jobId);
        fee = (1 * LINK_DIVISIBILITY) / 10;
        url = _url;
        times = _times;
        path = _path;
    }

    function requestMultipleParameters() public onlyAuthorizedSender {
        Chainlink.Request memory req = _buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillMultipleParameters.selector
        );
        req._add("url", url);
        req._add("path", path);
        req._addInt("times", times);
        _sendChainlinkRequest(req, fee);
    }

    function fulfillMultipleParameters(
        bytes32 requestId,
        bytes32 reserveResponse
    ) public recordChainlinkFulfillment(requestId) {
        emit RequestMultipleFulfilled(requestId, uint256(reserveResponse));
        reserve = uint256(reserveResponse);
    }

    function setAuthorizedSender(
        address _authorizedSender
    ) public onlyOwnerOrAuthorized returns (bool) {
        emit NewAuthorizedSender(_authorizedSender);
        authorizedSender = _authorizedSender;
        return true;
    }

    function setJobId(string memory _jobId) public onlyOwner {
        emit JobIdUpdated(jobId);
        jobId = stringToBytes32(_jobId);
    }

    function setUrl(string memory _url) public onlyOwner {
        emit UrlUpdated(url);
        url = _url;
    }

    function setPath(string memory _path) public onlyOwner {
        emit PathUpdated(path);
        path = _path;
    }

    function setTimes(int256 _times) public onlyOwner {
        emit TimesUpdated(times);
        times = _times;
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function stringToBytes32(
        string memory source
    ) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }

    function getChainlinkToken() public view returns (address) {
        return _chainlinkTokenAddress();
    }

    function getChainlinkOracle() public view returns (address) {
        return _chainlinkOracleAddress();
    }
}
