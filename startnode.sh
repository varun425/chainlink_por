#!/bin/bash

POSTGRES_CONTAINER_NAME="postgres"
POSTGRES_PASSWORD="mypostgresspassword123456"  # Note: Consider using a more secure method for password handling
CHAINLINK_CONTAINER_NAME="chainlink"
CHAINLINK_DIR="$HOME/.chainlink-sepolia"
POSTGRES_PORT="5432:5432"
CHAINLINK_PORT="6688:6688"
CHAINLINK_IMAGE="smartcontract/chainlink:2.10.0"

echo "Starting PostgreSQL container..."
docker run --name $POSTGRES_CONTAINER_NAME -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD -p $POSTGRES_PORT -d postgres
if [ $? -ne 0 ]; then
    echo "Failed to start PostgreSQL container."
    exit 1
fi

echo "Waiting for PostgreSQL to initialize..."
sleep 2s  

# Start the Chainlink node
echo "Starting Chainlink node..."
cd $CHAINLINK_DIR && docker run --platform linux/x86_64/v8 --name $CHAINLINK_CONTAINER_NAME -v $CHAINLINK_DIR:/chainlink -it -p $CHAINLINK_PORT --add-host=host.docker.internal:host-gateway $CHAINLINK_IMAGE node -config /chainlink/config.toml -secrets /chainlink/secrets.toml start
if [ $? -ne 0 ]; then
    echo "Failed to start Chainlink node."
    exit 1
fi

echo "Chainlink node started successfully."
