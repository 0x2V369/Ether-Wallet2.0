//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

// @authoer 2V
// @title EtherWalletForMultipleEOAs

contract EtherWallet2{

    address public owner;
    address[] private guardianList;
    uint8 private constant MINIMUM_VOTE_COUNT = 3;

    event ReceivedFunds(address indexed from, uint256 amount, uint256 fundsAvailable, uint256 timestamp);
    event WithdrawFunds(address indexed from, address indexed to, uint256 amount, uint256 fundsAvailable, uint256 timestamp);
    event VoteForNewOwner(address indexed from, address indexed votedFor, uint256 timestamp);
    event NewOwnerSet(address indexed newOwner, uint256 timestamp);

    mapping(address => bool) private guardians;
    mapping(address => uint256) private allowance;
    mapping(address => mapping(address => bool)) private votes;
    mapping(address => uint256) public balances;


    /// @dev Ensures that only the contract owner can execute the function
    modifier onlyOwner{
        require(msg.sender == owner, "You must be wallet owner for this action");
        _;
    }

    /// @dev Ensures that only guardians can execute the function
    modifier onlyGuardian{
        require(guardians[msg.sender], "Only wallet Guardians are allowed to vote for new wallet owner.");
        _;
    }

    /// @dev Sets the contract deployer as the owner and the first guardian
    constructor(){
        owner = msg.sender;
        guardians[msg.sender] = true;
        guardianList.push(msg.sender);
    }

    /// @dev Allows the contract to receive Ether and records the deposit
    receive() external payable {
        deposit();
    }

    /// @dev Fallback function to handle plain Ether transfers and records the deposit
    fallback() external payable {
        deposit();
    }

    /// @dev Records the deposit and updates the sender's balance
    function deposit() public payable {
        balances[msg.sender] = msg.value;
        emit ReceivedFunds(msg.sender, msg.value, balances[msg.sender], block.timestamp);
    }

    /// @dev Allows the sender to withdraw a specified amount of Ether to a specified address
    /// @param to The address to send the Ether to
    /// @param amount The amount of Ether to withdraw
    function withdraw(address payable to, uint256 amount) public {
        require(amount <= allowance[msg.sender], "Withdraw amount is larger than allowance, increase your allowance.");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        allowance[msg.sender] -= amount; // Adjust allowance after withdrawl

        (bool success, ) = to.call{value : amount}("");
        require(success, "Withdraw unsuccesful");

        emit WithdrawFunds(msg.sender, to, amount, balances[msg.sender], block.timestamp);
    }

    /// @dev Adds a new guardian
    /// @param newGuardian The address of the new guardian
    function addGuardian(address newGuardian) public onlyOwner {
        require(!guardians[newGuardian], "Address is already a guardian");
        guardians[newGuardian] = true;
        guardianList.push(newGuardian);
    }

    /// @dev Sets the allowance for a specified address
    /// @param addr The address for which to set the allowance
    /// @param newAllowance The new allowance amount
    function setAllowance(address addr, uint256 newAllowance) public {
        allowance[addr] = newAllowance;
    }

    /// @dev Resets the allowance for a specified address
    /// @param addr The address for which to reset the allowance
    function resetAddressAllowance(address addr) public {
        allowance[addr] = 0;
    }
    
    /// @dev Allows guardians to vote for a new owner
    /// @param candidate The address of the candidate for the new owner
    function voteNewOwner(address candidate) public onlyGuardian{
        require(candidate != owner, "Address is already the wallet owner");
        require(!votes[msg.sender][candidate], "You have already voted for this candidate");

        votes[msg.sender][candidate] = true;
        emit VoteForNewOwner(msg.sender, candidate, block.timestamp);

        //check total votes for the give address _votingFor
        if(countTrueVotes(candidate) >= MINIMUM_VOTE_COUNT){
            setNewOwner(candidate);
            emit NewOwnerSet(candidate, block.timestamp);
        }
    }

    /// @dev Counts the number of true votes for a specified address
    /// @param candidate The address to count votes for
    /// @return count The number of votes
    function countTrueVotes(address candidate) public view returns (uint8) {
        uint8 count = 0;
        for(uint i = 0; i < guardianList.length; i++){
            if(votes[guardianList[i]][candidate]){
                count++;
            }
        }
        return count;
    }

    /// @dev Sets the new owner of the contract
    /// @param newOwner The address of the new owner
    function setNewOwner(address newOwner) internal {
        owner = newOwner;
    }

    /// @dev Checks if an address is a guardian
    /// @param guardianAddress The address to check
    /// @return True if the address is a guardian, false otherwise
    function checkGuardian(address guardianAddress) public view returns(bool){
        return guardians[guardianAddress];
    }

    /// @dev Checks the allowance of a specified address
    /// @param addr The address to check
    /// @return The allowance amount
    function checkAllowance(address addr) public view returns(uint256) {
        return allowance[addr];
    }
}