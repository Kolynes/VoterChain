var VoterChainContract = artifacts.require("./contracts/VoterChainContract.sol");

module.exports = function(deployer) {
  deployer.deploy(VoterChainContract);
};
