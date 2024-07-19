### Prerequisites

- Ensure you have a running Chainlink node.
- Ensure your external adapter is running and accessible, e.g., `http://localhost:3000`.
- Ensure ports are open and there's no firewall blocking the Chainlink node from accessing the external adapter.

### Steps

1. Deploy Chainlink Node:

   - Follow the official Chainlink documentation to deploy and configure your Chainlink node.
   - Ensure the node is running and can interact with the Ethereum network.

2. Run External Adapter:

   - Start your external adapter and ensure it’s running on a specific port, e.g., `http://localhost:3000`.
   - Verify that the external adapter is accessible and responding correctly.

3. Deploy Chainlink Oracle:

   - Deploy the Chainlink Oracle contract using either OracleFactory or Oracle library.
   - Note the address of the deployed Oracle contract.

4. Set Authorized Senders:

   - Use the `setAuthorizedSender()` function in your Oracle contract to authorize the Chainlink node.
   - Example:
     ```solidity
     oracleContract.setAuthorizedSender(chainlinkNodeAddress);
     ```

5. Configure Direct Request Job:

   - In the Chainlink node, create a Direct Request job.
   - Update the job with the following fields:
     - `externalJobID`: Unique ID for the job.
     - `contractAddress`: Address of the Oracle contract.
     - `evmChainID`: ID of the Ethereum network.
     - `fetch->url`: URL of the external adapter.
     - `fetch->path`: Path to the data in the API response.
     - `fetch->multiply`: Multiplier for the data (if needed).
     - `submit_tx->to`: Address of the Oracle contract.

6. Deploy `GetReserve.sol` Contract:

   - Deploy the `GetReserve` contract on the same network where the Oracle is deployed.
   - Fill the constructor with the required values:
     ```solidity
     constructor(
         address chainlinkToken,
         address chainlinkOracle,
         string memory _jobId,
         uint256 LINK_DIVISIBILITY,
         string memory _url,
         string memory _path,
         int256 _times
     ) { ... }
     ```
   - Ensure the values for `externalJobID`, `url`, `path`, and `times` match those provided in the Direct Request job configuration.

7. Create Cron Job in Chainlink Node:

   - In the Chainlink node, create a Cron job that triggers the `requestMultipleParameters` function of the `GetReserve` contract.
   - Update the Cron job with the necessary fields:
     - `fetch->url`: URL of the external adapter.
     - `fetch->path`: Path to the data in the API response.
     - `fetch->multiply`: Multiplier for the data (if needed).
     - `encode_tx->func()`: Encoded function signature for `requestMultipleParameters`.
     - `submit_tx->to`: Address of the `GetReserve` contract.

8. Monitor and Verify:
   - Monitor the Chainlink node logs to ensure the jobs are running as expected.
   - Verify the output by checking the `getReserve` variable in the `GetReserve` contract.

### Notes

- Ensure the Chainlink node can communicate with the external adapter.
- Ensure all contract addresses and job IDs are correctly referenced.
- Regularly monitor and maintain the node, adapter, and smart contracts for optimal performance.

By following these steps, you will be able to deploy and run Chainlink jobs efficiently in a production environment.
