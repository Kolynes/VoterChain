// SPDX-License-Identifier: MIT

pragma solidity ^0.5.4;

import "./VoterChainElectionContract.sol";

contract VoterChainElectionsTrackerContract {
    mapping(uint => VoterChainElectionContract) public elections;
    uint public numberOfElections;
    address public owner;

    event ElectionCreated(address election);

    constructor() public {
        owner = msg.sender;
    }

    function getElection(uint index) 
        public 
        view 
        returns(
            address electionContractAddress, 
            string memory name, 
            uint timestamp, 
            uint numberOfVoters, 
            uint numberOfCandidates, 
            bool votingIsActive, 
            bool registrationIsActive, 
            bool electionIsClosed
        )
    {
        VoterChainElectionContract electionContract = elections[index];
        electionContractAddress = address(elections[index]);
        name = electionContract.name();
        timestamp = electionContract.timestamp();
        numberOfVoters = electionContract.numberOfVoters();
        numberOfCandidates = electionContract.numberOfCandidates();
        votingIsActive = electionContract.votingIsActive();
        registrationIsActive = electionContract.registrationIsActive();
        electionIsClosed = electionContract.electionIsClosed();
    }

    function createElection(string memory name) 
        public 
        returns(bool)
    {
        require(owner == msg.sender);
        VoterChainElectionContract election = new VoterChainElectionContract(owner, name);
        elections[numberOfElections] = election;
        numberOfElections++;
        emit ElectionCreated(address(election));
        return true;
    }
    
}