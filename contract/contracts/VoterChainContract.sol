// SPDX-License-Identifier: MIT

pragma solidity ^0.5.4;

contract VoterChainContract {
    struct Candidate {
        bytes pictureData;
        uint numberOfVotes;
        bool valid;
    }

    struct Voter {
        string name;
        bool hasVoted;
        bool registered;
    }

    event CandidateAdded(address candidateAddress);
    event VoterRegistered(address voterAddress);
    event VoteCast(address candidateAddress);

    address public owner;

    mapping(address => Candidate) public candidates;
    mapping(uint => address) public candidateAddresses;
    mapping(address => Voter) public voters;

    uint numberOfCandidates;
    uint numberOfVoters;

    constructor() public {
        owner = msg.sender;
    }

    modifier isOwner {
        require(msg.sender == owner);
        _;
    }

    modifier isCandidate(address candidateAddress) {
        require(candidates[candidateAddress].valid);
        _;
    }

    modifier isVoter {
        require(voters[msg.sender].registered);
        _;
    }

    modifier hasNotVoted {
        require(!voters[msg.sender].hasVoted);
        _;
    }

    function registerVoter(address voterAddress, string memory name) public isOwner {
        if(voters[voterAddress].registered)
            revert("voter already registered");
        else {
            voters[voterAddress] = Voter({
                name: name,
                hasVoted: false,
                registered: true
            });
            numberOfVoters++;
            emit VoterRegistered(voterAddress);
        }
    }

    function addCandidate(address candidateAddress, string memory name, bytes memory pictureData) public isOwner {
        if(candidates[candidateAddress].valid)
            revert("candidate already added");
        else {
            candidates[candidateAddress] = Candidate({
                valid: false,
                pictureData: pictureData,
                numberOfVotes: 0
            });
            candidateAddresses[numberOfCandidates] = candidateAddress;
            numberOfCandidates++;
            emit CandidateAdded(candidateAddress);
            registerVoter(candidateAddress, name);
        }
    }

    function vote(address candidateAddress) public isCandidate(candidateAddress) isVoter hasNotVoted {
        candidates[candidateAddress].numberOfVotes++;
        voters[msg.sender].hasVoted = true;
        emit VoteCast(candidateAddress);
    }
}