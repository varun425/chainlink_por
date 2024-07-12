###### Author : Varun Arya

# Chainlink Local Node Setup Guide

## Prerequisites
- Docker
- PostgreSQL

## Setup PostgreSQL in Docker
Run the following command to set up PostgreSQL in Docker:

```bash
docker run --name postgres -e POSTGRES_PASSWORD=mypostgresspassword123456 -p 5432:5432 -d postgres
```

> **Note:** Ensure the PostgreSQL password is at least 16 characters long.

## Create Chainlink Directory
Create a directory for Chainlink configuration:

```bash
mkdir ~/.chainlink-sepolia
```

## Configuration Files
### config.toml
Create `config.toml` in the `~/.chainlink-sepolia` directory with the following content:

```bash                                                            
echo [Log]
Level = 'debug'

[WebServer]
AllowOrigins = '\*'
SecureCookies = false

[WebServer.TLS]
HTTPSPort = 0

[[EVM]]
ChainID = '4002'
LinkContractAddress = '0x5e8df0a791232cca30850189a8ee29C651F2d1b0'

[[EVM.Nodes]]
Name = 'Fantom'
WSURL = 'wss://fantom-testnet-rpc.publicnode.com/'
HTTPURL = 'https://rpc.ankr.com/fantom_testnet/'
" > ~/.chainlink-sepolia/config.toml
```

> **Note:** You can change the RPC URL, Chain ID, Link token, and WSS as required.

### secrets.toml
Create `secrets.toml` in the `~/.chainlink-sepolia` directory with the following content:

```bash
echo [Password]
Keystore = 'mypostgresspassword123456'

[Database]
URL = 'postgresql://postgres:mypostgresspassword123456@host.docker.internal:5432/postgres?sslmode=disable'
AllowSimplePasswords = false
" > ~/.chainlink-sepolia/secrets.toml
```

## Start Chainlink Node
Navigate to the Chainlink directory and run the following command:

```bash
cd ~/.chainlink-sepolia && docker run --platform linux/x86_64/v8 --name chainlink -v ~/.chainlink-sepolia:/chainlink -it -p 6688:6688 --add-host=host.docker.internal:host-gateway smartcontract/chainlink:2.10.0 node -config /chainlink/config.toml -secrets /chainlink/secrets.toml start
```

## Node Manager Setup
After starting the node, set up the email and password for the node manager.

## Funding the Node Wallet
Each node is assigned a wallet address responsible for calling operator or oracle fulfillment functions. This wallet address must be funded with LINK tokens and native tokens.

## Node, Oracle, and Chainlink Contract Workflow
1. The node setup includes WSS and HTTP URLs for the selected network.
2. When a Chainlink contract function is triggered, it calls the `_sendChainlinkRequest` function, which is inherited from the oracle contract.
3. The oracle contract emits an oracle request event. The node catches this event using the external job ID present in both the node and the Chainlink contract.
4. The oracle contract communicates with the external adapter, fetches data, and sends it back to the Chainlink contract by calling the fulfillment request.
5. The fee for this process is paid by the node wallet address, hence it needs to be pre-funded.

## Summary
This guide provides a step-by-step process for setting up a Chainlink node locally using Docker and PostgreSQL. Ensure the configuration files are correctly set up and the node wallet is adequately funded for smooth operation.
