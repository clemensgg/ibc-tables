# IBC-Tables
IBC-Tables is a repository dedicated to visualizing all active Inter-Blockchain Communication (IBC) connections, also known as IBC paths, in the Interchain ecosystem.

## What is an IBC Path?
An IBC path is a series of entities that facilitate communication between two independent blockchains in the Interchain ecosystem. Each IBC path consists of a client, a connection, a port, and a channel:

- Client: A light client is a piece of software that can verify the consensus transcript of a blockchain. Each IBC connection is associated with a pair of light clients: one light client on the source chain and one on the destination chain. Each light client verifies the consensus of the other chain.

- Connection: Once a client is created on a chain, a connection can be established between the clients of two chains. This connection is bidirectional and can facilitate packet transmission in both directions.

- Port: A port represents a module or subset of modules within a blockchain application that has been assigned as the end application of the IBC connection. Any module within the blockchain application can own a port and thus manage its own IBC connections.

- Channel: A channel is a pipe that allows the exchange of packets between two specific modules on two different chains, under the governance of a specific connection.


## Overview
This repository contains scripts that run daily workflows to fetch and update IBC connection data for each chain of the [⚛️ Cosmos chain-registry](https://github.com/cosmos/chain-registry). The data is fetched from each chain's public REST endpoint (using the REST relay provided by [❤️ cosmos.directory](https://cosmos.directory)), processed, and stored in this repository.

## Structure
The repository is primarily organized around the chains in the Cosmos chain-registry. Each chain has its own folder, and within each folder is a CSV file containing the latest IBC connection data for that chain.

## Workflow
The repository uses GitHub Actions to run daily workflows that update the IBC connection data. The workflow is specified in the mainnets.yml file located in the .github/workflows directory.

## License
This project is licensed under the terms of the MIT license.