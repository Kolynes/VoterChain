import { Action, Module, Mutation, MutationAction, VuexModule } from "vuex-module-decorators";
import Provider from "@/plugins/provider";


@Module({ namespaced: true })
export default class AdminModule extends VuexModule {
	elections: IElection[] = [];
	selectedElection: IElection | null = null;
	candidates: ICandidate[] = [];
	numberOfVoters: number = 0;
	trackerContractAddress: string = "";

	@Mutation
	setTrackerContractAddress(payload: { trackerContractAddress: string }) {
		this.trackerContractAddress = payload.trackerContractAddress;
		this.selectedElection = null;
		this.elections = [];
		localStorage.setItem("trackerContractAddress", payload.trackerContractAddress);
	}

	@Mutation
	setSelectedElection(payload: { election: IElection }) {
		this.selectedElection = payload.election;
	}

	@Mutation
	addCandidateDirectly(payload: { candidate: ICandidate }) {
		this.candidates.push(payload.candidate);
	}

	@MutationAction({ mutate: ["elections", "selectedElection"] })
	async getElections() {
		try {
			const { numberOfElections } = await Provider.call<{ numberOfElections: number }>({
				name: "numberOfElections",
				to: (this.state as this).trackerContractAddress,
				outputs: [
					{ type: "uint256", name: "numberOfElections" }
				]
			});
			let elections: IElection[] = [];
			for (let i = 0; i < numberOfElections; i++)
				elections.push(await Provider.call<IElection>({
					name: "getElection",
					to: (this.state as this).trackerContractAddress,
					inputs: [
						{ type: "uint256", name: "index", value: i.toString() }
					],
					outputs: [
						{ type: "address", name: "address" },
						{ type: "string", name: "name" },
						{ type: "uint256", name: "timestamp" },
						{ type: "uint256", name: "numberOfVoters" },
						{ type: "uint256", name: "numberOfCandidates" },
						{ type: "bool", name: "votingIsActive" },
						{ type: "bool", name: "registrationIsActive" },
						{ type: "bool", name: "electionIsClosed" },
					],
				}));
			let selectedElection: IElection | null = (this.state as this).selectedElection;
			if (!selectedElection)
				selectedElection = elections.length > 0 ? elections[0] : null;
			else for (var election of elections)
				if (selectedElection.address == election.address) {
					selectedElection = election;
					break;
				}
			return {
				elections,
				selectedElection
			};
		} catch (error) {
			console.error(error.message, error.stack);
			return {
				elections: (this.state as this).elections,
				selectedElection: (this.state as this).selectedElection
			};
		}
	}

	@MutationAction({ mutate: ["candidates"] })
	async getCandidates() {
		try {
			const { numberOfCandidates } = await Provider.call<{ numberOfCandidates: number }>({
				name: "numberOfCandidates",
				to: ((this.state as this).selectedElection as IElection).address || "",
				outputs: [
					{ type: "uint256", name: "numberOfCandidates" }
				]
			});
			let candidates: ICandidate[] = [];
			for (let i = 0; i < numberOfCandidates; i++)
				candidates.push(await Provider.call<ICandidate>({
					name: "getCandidate",
					to: ((this.state as this).selectedElection as IElection).address || "",
					inputs: [
						{ type: "uint8", name: "index", value: i.toString() }
					],
					outputs: [
						{ type: "string", name: "name", },
						{ type: "uint256", name: "numberOfVotes", },
						{ type: "address", name: "address", },
					]
				}));
			return { candidates };
		} catch (error) {
			console.error(error.message, error.stack);
			return {
				candidates: (this.state as this).candidates
			}
		}
	}

	@MutationAction({ mutate: ["numberOfVoters"] })
	async getNumberOfVoters() {
		try {
			return await Provider.call<{ numberOfVoters: number }>({
				name: "numberOfVoters",
				to: ((this.state as this).selectedElection as IElection).address || "",
				outputs: [
					{ type: "uintt256", name: "numberOfVoters" }
				]
			});
		} catch (error) {
			console.error(error.message, error.stack);
			return {
				numberOfVoters: (this.state as this).numberOfVoters
			}
		}
	}

	@Action
	async createElection(payload: { name: string }): Promise<boolean> {
		try {
			const { result } = await Provider.sendTransaction<{ result: boolean }>({
				name: "createElection",
				inputs: [
					{ type: "string", name: "name", value: payload.name }
				],
				outputs: [
					{ type: "bool", name: "result" }
				],
				to: this.trackerContractAddress,
			});
			return result;
		} catch (error) {
			console.error(error.message, error.stack);
			return false;
		}
	}

	@Action
	async getVoter(payload: { address: string }): Promise<IVoter | null> {
		try {
			return await Provider.call<IVoter>({
				name: "getVoter",
				inputs: [
					{ type: "address", name: "voterAddress", value: payload.address }
				],
				outputs: [
					{ type: "string", name: "name" },
					{ type: "bool", name: "hasVoted" },
					{ type: "bool", name: "registered" },
					{ type: "address", name: "address" },
				],
				to: (this.selectedElection as IElection).address || "",
			});
		} catch (error) {
			console.error(error.message, error.stack);
			return null;
		}
	}

	@Action
	async addCandidate(payload: { candidateAddress: string, name: string, pictureData: string }): Promise<boolean> {
		try {
			const { result } = await Provider.sendTransaction<{ result: boolean }>({
				name: "addCandidate",
				to: (this.selectedElection as IElection).address || "",
				inputs: [
					{ type: "address", name: "candidateAddress", value: payload.candidateAddress },
					{ type: "string", name: "candidateName", value: payload.name },
				],
				outputs: [
					{ type: "bool", name: "result" }
				]
			});
			if (result)
				this.context.commit("addCandidateDirectly", { candidate: {
					address: payload.candidateAddress,
					name: payload.name,
					numberOfVotes: 0
				} as ICandidate});
			return result;
		} catch (error) {
			console.error(error.message, error.stack);
			return false;
		}
	}

	@Action
	async registerVoter(payload: { voterAddress: string, name: string }): Promise<boolean> {
		try {
			const { result } = await Provider.sendTransaction<{ result: boolean }>({
				name: "registerVoter",
				to: (this.selectedElection as IElection).address || "",
				inputs: [
					{ type: "address", name: "voterAddress", value: payload.voterAddress },
					{ type: "string", name: "voterName", value: payload.name },
				],
				outputs: [
					{ type: "bool", name: "result" }
				]
			});
			return result;
		} catch (error) {
			console.error(error.message, error.stack);
			return false;
		}
	}

	@Action
	async activateVoting(): Promise<boolean> {
		try {
			const { result } = await Provider.sendTransaction<{ result: boolean }>({
				name: "activateVoting",
				to: (this.selectedElection as IElection).address || "",
				outputs: [
					{ type: "bool", name: "result" }
				],
			});
			if (result)
				this.context.dispatch("getElections")
			return result;
		} catch (error) {
			console.error(error.message, error.stack);
			return false;
		}
	}

	@Action
	async closeElection(): Promise<boolean> {
		try {
			const { result } = await Provider.sendTransaction<{ result: boolean }>({
				name: "closeElection",
				to: (this.selectedElection as IElection).address || "",
				outputs: [
					{ type: "bool", name: "result" }
				],
			});
			if (result)
				this.context.dispatch("getElections");
			return result;
		} catch (error) {
			console.error(error.message, error.stack);
			return false;
		}
	}
}
