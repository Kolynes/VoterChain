import {Action, Module, MutationAction, VuexModule} from "vuex-module-decorators";

@Module({namespaced: true})
export default class AdminModule extends VuexModule {
    readonly contract = window.tronWeb.contract().at("TToUDT2FLfEDkSbtvNuQfuo5Q8amqBL4go");
    candidates: ICandidate[] = [];
    numberOfVoters: number = 0;
    
    @Action
    async getVoter(address: string): Promise<IVoter | null> {
        try {
            return (await this.contract.voters(address).call()) as IVoter;
        }
        catch(error) {
            console.log(error.message);
            return null;
        }
    }

    @MutationAction({mutate: ["candidates"]})
    async getCandidates() {
        try {
            var numberOfCandidates = await this.contract.numberOfCandidates().call();
            var candidates: ICandidate[] = [];
            for(var i = 0; i < numberOfCandidates; i++)
                candidates.push(await this.contract.candidatesAddresses(i).call())
            return {
                candidates
            };
        } catch(error) {
            console.log(error.message);
            return {
                candidates: []
            }
        }
    }

    @MutationAction({mutate: ["numberOfVoters"]})
    async getNumberOfVoters() {
        try {
            return {
                numberOfVoters: await this.contract.numberOfVoters().call()
            }
        } catch(error) {
            console.log(error.message);
            return {
                numberOfVoters: 0
            }
        }
    }

    @Action
    async addCandidate(candidateAddress: string, name: string, pictureData: string): Promise<boolean> {
        
    }

    @Action
    async registerVoter(voterAddress: string, name: string): Promise<boolean> {

    }
}