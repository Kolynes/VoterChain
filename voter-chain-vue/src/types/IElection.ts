interface IElection {
  name: string;
  address: string;
  timestamp: number;
  numberOfVoters: number;
  numberOfCandidates: number;
  votingIsActive: boolean;
  registrationIsActive: boolean;
  electionIsClosed: boolean;
}