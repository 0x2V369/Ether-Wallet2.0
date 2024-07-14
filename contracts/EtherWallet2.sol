//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

// @authoer 2V
// @title EtherWalletForMultipleEOAs

contract EtherWallet2{

    address public owner;
    address[] private guardianList;
    

    event ReceivedFunds(address indexed from, uint256 amount, uint256 fundsAvailable, uint256 timestamp);
    event WithdrawFunds(address indexed from, address indexed to, uint256 amount, uint256 fundsAvailable, uint256 timestamp);
    event VoteForNewOwner(address indexed from, address indexed votedFor, uint256 timestamp);
    event NewOwnerSet(address indexed newOwner, uint256 timestamp);

    mapping(address => bool) private guardians;
    mapping(address => uint256) private allowance;
    mapping(address => mapping(address => bool)) private votes;
    mapping(address => uint256) public balances;

    modifier onlyOwner{
        require(msg.sender == owner, "You must be wallet owner for this action");
        _;
    }

    modifier onlyGuardian{
        require(guardians[msg.sender], "Only wallet Guardians are allowed to vote for new wallet owner.");
        _;
    }

    constructor(){
        owner = msg.sender;
        guardians[msg.sender] = true;
        guardianList.push(msg.sender);
    }

    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
     }

    function deposit() public payable {
        emit ReceivedFunds(msg.sender, msg.value, balances[msg.sender], block.timestamp);
        balances[msg.sender] = msg.value;
    }

    function withdraw(address payable to, uint256 amount) public {
        require(amount <= allowance[msg.sender], "Withdraw amount is larger than allowance, increase your allowance.");
        balances[msg.sender] -= amount;

        (bool success, ) = to.call{value : amount}("");
        require(success, "Withdraw unsuccesful");

        emit WithdrawFunds(msg.sender, to, amount, balances[msg.sender], block.timestamp);
    }

    function addGuardian(address newGuardian) public onlyOwner {
        guardians[newGuardian] = true;
        guardianList.push(newGuardian);
    }

    function setAllowance(address addressAllowance, uint256 newAllowance) public {
        allowance[addressAllowance] = newAllowance;
    }

    function resetAddressAllowance(address resetAddress) public {
        allowance[resetAddress] = 0;
    }
    
    function voteNewOwner(address votingFor) public onlyGuardian{
        require(votingFor != owner, "Address that you are trying to vote for is already the wallet Owner");
        require(votes[msg.sender][votingFor] == false, "You have already voted for this Guardian address");

        votes[msg.sender][votingFor] = true;
        emit VoteForNewOwner(msg.sender, votingFor, block.timestamp);

        //check total votes for the give address _votingFor
        if(countTrueVotes(votingFor) >= 3){
            setNewOwner(votingFor);
            emit NewOwnerSet(votingFor, block.timestamp);
        }

    }

    function countTrueVotes(address _address) public view returns (uint256) {
        uint256 count = 0;
        for(uint i = 0; i < guardianList.length; i++){
            if(votes[guardianList[i]][_address]){
                count++;
            }
        }

        return count;
    }

    function setNewOwner(address newOwner) internal {
        owner = newOwner;
    }

    function checkGuardian(address guardianAddress) public view returns(bool){
        return guardians[guardianAddress];
    }

    function checkAllowance(address addressToCheck) public view returns(uint256) {
        return allowance[addressToCheck];
    }
}