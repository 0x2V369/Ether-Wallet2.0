```markdown
# EtherWalletForMultipleEOAs

## Overview

`EtherWalletForMultipleEOAs` is a Solidity smart contract designed to manage Ether funds for multiple externally owned accounts (EOAs) through a guardian system. This contract allows an owner to manage funds while enabling a group of trusted guardians to participate in governance decisions, such as voting for a new owner.

## Features

- **Owner Management**: The contract has a designated owner who can manage funds and add guardians.
- **Guardian Voting**: Guardians can vote to elect a new owner, requiring a minimum number of votes for the change.
- **Allowance System**: Each address can have an allowance, determining how much they can withdraw.
- **Deposit and Withdraw**: Users can deposit Ether into the contract and withdraw funds based on their allowance.

## Events

- `ReceivedFunds(address indexed from, uint256 amount, uint256 fundsAvailable, uint256 timestamp)`: Emitted when funds are received.
- `WithdrawFunds(address indexed from, address indexed to, uint256 amount, uint256 fundsAvailable, uint256 timestamp)`: Emitted when funds are withdrawn.
- `VoteForNewOwner(address indexed from, address indexed votedFor, uint256 timestamp)`: Emitted when a guardian votes for a new owner.
- `NewOwnerSet(address indexed newOwner, uint256 timestamp)`: Emitted when a new owner is set.

## Contract Structure

The contract utilizes the following mappings:

- `mapping(address => bool) private guardians`: Tracks whether an address is a guardian.
- `mapping(address => uint256) private allowance`: Manages withdrawal limits for each address.
- `mapping(address => mapping(address => bool)) private votes`: Records voting actions for electing a new owner.
- `mapping(address => uint256) public balances`: Tracks the balance of each address.

## Functions

- `deposit()`: Allows users to deposit Ether into the contract.
- `withdraw(address payable to, uint256 amount)`: Allows users to withdraw funds, subject to their allowance.
- `addGuardian(address newGuardian)`: Allows the owner to add a new guardian.
- `setAllowance(address addr, uint256 newAllowance)`: Sets the allowance for a specified address.
- `resetAddressAllowance(address addr)`: Resets the allowance for a specified address.
- `voteNewOwner(address candidate)`: Allows guardians to vote for a new owner.
- `countTrueVotes(address candidate)`: Returns the count of votes for a specified address.
- `checkGuardian(address guardianAddress)`: Checks if an address is a guardian.
- `checkAllowance(address addr)`: Returns the allowance for a specified address.

## Security Considerations

1. **Access Control**: The use of modifiers ensures that only the owner or guardians can perform certain actions.
2. **Gas Optimization**: The contract has been optimized for gas efficiency where applicable, such as minimizing state variable writes.
3. **Voting Mechanism**: The voting process ensures that a minimum number of votes is required to change the owner, enhancing security against malicious actions.

## Installation

To deploy the contract, ensure you have the following prerequisites:

- Node.js
- Truffle or Hardhat (for deployment and testing)
- A compatible Ethereum wallet (e.g., MetaMask)

Clone the repository and run:

```bash
npm install
```

Deploy the contract using your preferred Ethereum network.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by decentralized governance models.
- Developed as part of a learning project in Solidity.
