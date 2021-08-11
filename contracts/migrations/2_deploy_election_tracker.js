const VoterChainElectionsTrackerContract = artifacts.require("./contracts/VoterChainElectionsTrackerContract.sol");

module.exports = function(deployer) {
    deployer.deploy(VoterChainElectionsTrackerContract);
};