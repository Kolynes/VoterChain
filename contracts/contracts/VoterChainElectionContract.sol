// SPDX-License-Identifier: MIT

pragma solidity ^0.5.4;

contract VoterChainElectionContract {
    struct Candidate {
        uint numberOfVotes;
        address addr;
    }

    struct Voter {
        string name;
        bool hasVoted;
        bool registered;
        address addr;
    }

    event CandidateAdded(address candidateAddress);
    event VoterRegistered(address voterAddress);
    event VoteCast(address candidateAddress);
    event VotingActivated();
    event VotingDeactivated();
    event ElectionClosed();

    address public owner;
    string public name;
    uint public timestamp;
    uint public numberOfCandidates;
    uint public numberOfVoters;
    bool public votingIsActive;
    bool public registrationIsActive;
    bool public electionIsClosed;

    Candidate[] public candidates;
    Voter[] public voters;

    constructor(address contractOwner, string memory contractName) public {
        owner = contractOwner;
        name = contractName;
        timestamp = now;
        registrationIsActive = true;
        votingIsActive = false;
        electionIsClosed = false;
    }

    modifier isOwner {
        require(msg.sender == owner);
        _;
    }

    function activateVoting() 
        public
        isOwner
        returns (bool) 
    {
        require(!electionIsClosed);
        votingIsActive = true;
        registrationIsActive = false;
        emit VotingActivated();
        return true;
    }

    function deactivateVoting() public isOwner {
        require(!electionIsClosed);
        votingIsActive = false;
        emit VotingDeactivated();
    }

    function closeElection() public isOwner {
        require(!electionIsClosed);
        votingIsActive = false;
        if(registrationIsActive)
            registrationIsActive = false;
        electionIsClosed = true;
        emit ElectionClosed();
    }

    function registerVoter(address voterAddress, string memory voterName) 
        public 
        isOwner
        returns(bool)
    {
        require(!electionIsClosed);
        require(registrationIsActive);
        for(uint8 i = 0; i < numberOfVoters; i++)
            if(voters[i].addr == voterAddress)
                revert("voter already registered");
        voters.push(Voter({
            name: voterName,
            hasVoted: false,
            registered: true,
            addr: voterAddress
        }));
        numberOfVoters++;
        emit VoterRegistered(voterAddress);
        return true;
    }

    function addCandidate(address candidateAddress, string memory candidateName)
        public
        isOwner
        returns (bool)
    {
        require(!electionIsClosed);
        require(registrationIsActive);
        for(uint i = 0; i < numberOfCandidates; i++)
            if(candidates[i].addr == candidateAddress)
                revert("candidate already added");
        candidates.push(Candidate({
            addr: candidateAddress,
            numberOfVotes: 0
        }));
        
        numberOfCandidates++;
        emit CandidateAdded(candidateAddress);
        return registerVoter(candidateAddress, candidateName);
    }

    function vote(uint candidate)
        public
        returns(bool)
    {
        Voter memory voter;
        for(uint8 i = 0; i < numberOfVoters; i++)
            if(voters[i].addr == msg.sender) {
                voter = voters[i];
                break;
            }            
        require(candidate < numberOfCandidates);
        require(!electionIsClosed);
        require(votingIsActive);
        require(voter.registered);
        require(!voter.hasVoted);
        candidates[candidate].numberOfVotes++;
        voter.hasVoted = true;
        emit VoteCast(candidates[candidate].addr);
        return true;
    }

    function getVoter(address voterAddress)
        public
        view
        returns (string memory voterName, bool hasVoted, bool registered, address addr)
    {
        for(uint8 i = 0; i < numberOfVoters; i++)
            if(voters[i].addr == voterAddress) {
                voterName = voters[i].name;
                hasVoted = voters[i].hasVoted;
                registered = voters[i].registered;
                addr = voters[i].addr;
                break;
            }
    }

    function getCandidate(uint8 index)
        public
        view
        returns (string memory candidateName, uint numberOfVotes, address addr)
    {
        (candidateName, , , addr) = getVoter(candidates[index].addr);
        numberOfVotes = candidates[index].numberOfVotes;
    }
}