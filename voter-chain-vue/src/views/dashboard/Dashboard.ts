import { Component, Ref, Vue, Watch } from "vue-property-decorator";
import { namespace } from "vuex-class";
import { requiredLengthRule, requiredRule } from "@/rules";
import VFileField from "@/vuetify-extensions/VFileField.vue";

const AdminModule = namespace("AdminModule");

@Component({
  components: {
    VFileField
  }
})
export default class Dashboard extends Vue {
  showSelectTrackerContractDialog: boolean = false;
  showAddCandidateDialog: boolean = false;
  showRegisterVoterDialog: boolean = false;
  showCreateElectionDialog: boolean = false;
  loadingElections: boolean = false;
  closingElection: boolean = false;
  activatingVoting: boolean = false;
  creatingNewElection: boolean = false;
  addingCandidate: boolean = false;
  registeringVoter: boolean = false;
  gettingVoter: boolean = false;

  localTrackerContractAddress: string = "";
  newElectionName: string = "";

  candidateAddress: string = "";
  candidateName: string = "";
  candidatePicture: File | null = null;

  voterAddress: string = "";
  voterName: string = "";

  voter: IVoter | null = null;
  voterAddressSearchString: string = "";

  tab: number = 0;

  @Ref()
  trackerContractAddressForm!: { validate: () => boolean, reset: () => void };

  @Ref()
  createElectionForm!: { validate: () => boolean, reset: () => void };

  @Ref()
  registerVoterForm!: { validate: () => boolean, reset: () => void };

  @Ref()
  addCandidateForm!: { validate: () => boolean, reset: () => void };

  @Ref()
  getVoterForm!: { validate: () => boolean, reset: () => void };

  @AdminModule.State
  trackerContractAddress!: string;

  @AdminModule.State
  elections!: any[];

  @AdminModule.State
  selectedElection!: IElection;

  @AdminModule.State
  candidates!: ICandidate[];

  @AdminModule.Mutation
  setTrackerContractAddress!: (payload: { trackerContractAddress: string }) => void;

  @AdminModule.Mutation
  setSelectedElection!: (payload: { election: IElection }) => void;

  @AdminModule.Action
  getElections!: () => Promise<void>;

  @AdminModule.Action
  createElection!: (payload: { name: string }) => Promise<void>;

  @AdminModule.Action
  activateVoting!: () => Promise<boolean>;

  @AdminModule.Action
  closeElection!: () => Promise<boolean>;

  @AdminModule.Action
  addCandidate!: (payload: { candidateAddress: string, name: string }) => Promise<boolean>;

  @AdminModule.Action
  registerVoter!: (payload: { voterAddress: string, name: string }) => Promise<boolean>;

  @AdminModule.Action
  getVoter!: (payload: { address: string }) => Promise<IVoter | null>;

  @AdminModule.Action
  getCandidates!: () => Promise<void>;


  requiredLengthRule = requiredLengthRule;
  requiredRule = requiredRule;

  validateEthAddress(value: string) {
    return value.startsWith("0x") || "Invalid ethereum address";
  }

  saveTrackerContractAddress() {
    if (this.trackerContractAddressForm.validate()) {
      this.setTrackerContractAddress({
        trackerContractAddress: this.localTrackerContractAddress
      });
      this.showSelectTrackerContractDialog = false;
      this.loadElections();
    }
  }

  async loadElections() {
    this.loadingElections = true;
    await this.getElections();
    this.loadingElections = false;
  }

  async callCreateElection() {
    if (this.createElectionForm.validate()) {
      this.creatingNewElection = true;
      await this.createElection({ name: this.newElectionName });
      this.creatingNewElection = false;
      this.showCreateElectionDialog = false; 
      this.createElectionForm.reset();
    }
  }

  callActivateVoting() {
    confirm({ title: "Activate Voting" }).then(async (result: boolean) => {
      if (result) {
        this.activatingVoting = true;
        var response = await this.activateVoting();
        this.activatingVoting = false;
        if (response)
          toast({ icon: "mdi-information-outline", message: "Voting Activated", iconColor: "white" });
        else toast({ icon: "mdi-information-outline", message: "Failed to activate voting", iconColor: "red" });
      }
    });
  }

  callCloseElection() {
    confirm({ title: "Close Election" }).then(async (result: boolean) => {
      if (result) {
        this.closingElection = true;
        const response = await this.closeElection();
        this.closingElection = false;
        if (response)
          toast({ icon: "mdi-information-outline", message: "Election Closed", iconColor: "white" });
        else toast({ icon: "mdi-information-outline", message: "Failed to close election", iconColor: "red" });
      }
    });
  }

  callAddCandidate() {
    if (this.addCandidateForm.validate())
      confirm({ title: "Add Candidate", icon: "mdi-account-plus-outline" }).then(async (result: boolean) => {
        if (result) {
          this.addingCandidate = true;
          const response = await this.addCandidate({
            candidateAddress: this.candidateAddress,
            name: this.capitalize(...this.candidateName.split(" ")),
          })
          this.addingCandidate = false;
          this.showAddCandidateDialog = false;
          if (response) 
            toast({ icon: "mdi-information-outline", message: "Candidate added", iconColor: "white" });
          else toast({ icon: "mdi-information-outline", message: "Failed to add candidate", iconColor: "red" });
        }
      })
  }

  callRegisterVoter() {
    if (this.registerVoterForm.validate())
      confirm({ title: "Register Voter", icon: "mdi-vote-outline" }).then(async (result: boolean) => {
        if (result) {
          this.registeringVoter = true;
          const response = await this.registerVoter({
            voterAddress: this.voterAddress,
            name: this.capitalize(...this.voterName.split(" ")),
          });
          this.registeringVoter = false;
          this.showRegisterVoterDialog = false;
          if (response)
            toast({ icon: "mdi-information", message: "Voter Registered", iconColor: "white" });
          else toast({ icon: "mdi-information", message: "Failed to register voter", iconColor: "red" })
        }
      })
  }

  async callGetVoter() {
    if (this.getVoterForm.validate()) {
      this.gettingVoter = true;
      this.voter = await this.getVoter({ address: this.voterAddressSearchString });
      this.gettingVoter = false;
      if (this.voter)
        toast({ icon: "mdi-information", message: "Voter Found", iconColor: "white" })
      else toast({ icon: "mdi-information", message: "Voter not found", iconColor: "red" })
    }
  }

  goHome() {
    this.$router.push("/")
  }

  capitalize(...strings: string[]): string {
    const temp: string[] = [];
    for (var str of strings) {
      str = str.trim();
      temp.push(str[0].toUpperCase() + str.substring(1))
    }
    return temp.join(" ");
  }

  currentState(election: IElection): string {
    if (election.registrationIsActive)
      return "Registration is active";
    else if (election.votingIsActive)
      return "voting is active";
    else return "Election is closed"
  }

  nextState(): { text: string, transition: Function } {
    if (this.selectedElection.registrationIsActive)
      return {
        text: "Start Voting",
        transition: this.callActivateVoting
      }
    else if (this.selectedElection.votingIsActive)
      return {
        text: "Close Election",
        transition: this.callCloseElection
      }
    else return {
      text: "Closed",
      transition: () => null
    }
  }

  @Watch("selectedElection")
  onSelectedElectionChanged() {
    this.getCandidates();
  }

  @Watch("showAddCandidateDialog")
  onShowAddCandidateDialogChanged() {
    this.addCandidateForm.reset();
  }

  @Watch("showRegisterVoterDialog")
  onShowRegisterVoterDialogChanged() {
    this.registerVoterForm.reset();
  }

  @Watch("showCreateElectionDialog")
  onShowCreateElectionDialogChanged() {
    this.createElectionForm.reset();
  }

  mounted() {
    this.localTrackerContractAddress = this.trackerContractAddress;
    if (this.localTrackerContractAddress == "")
      this.showSelectTrackerContractDialog = true;
    else {
      this.loadElections();
    }
  }

}