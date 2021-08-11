<template>
   <v-app>
    <v-app-bar fixed dense style="z-index: 10" flat>
      <v-avatar class="ml-1" @click="goHome">
        <img src="../../assets/images/logo.svg">
      </v-avatar>
      <h1 class="title ml-2 font-weight-light" @click="goHome">VoterChain</h1>
      <v-spacer/>
      <v-btn v-if="localTrackerContractAddress" class="primary mr-2 text-capitalize" tile @click="showCreateElectionDialog = true">
        <v-icon class="mr-2" >mdi-vote-outline</v-icon>
        <span>Create new Election</span>
      </v-btn>
      <v-btn class="primary text-capitalize" tile @click="showSelectTrackerContractDialog = true">
        <v-icon class="mr-2">mdi-network</v-icon>
        <span>Select Election Tracker Contract</span>
      </v-btn>
    </v-app-bar>
    <v-navigation-drawer :mobile-breakpoint="0" width="30%" style="top: 48px; height: calc(100vh - 48px);" clipped fixed>
      <template v-if="elections.length > 0">
        <v-toolbar dense style="position: fixed; z-index: 10; width: 100%">
          <span class="title">Elections</span>
          <v-spacer/>
          <v-btn icon color="primary" class="text-capitalize" :loading="loadingElections" @click="loadElections">
            <v-icon>mdi-refresh</v-icon>
          </v-btn>
        </v-toolbar>
        <v-list class="transparent" style="margin-top: 48px">
          <template v-for="(election, index) in elections">
            <v-list-item :key="index" @click="setSelectedElection({ election })" :class="selectedElection.address == election.address? 'primary' : ''">
              <v-list-item-content>
                <span class="text-capitalize">{{election.name}}</span>
                <span class="caption">{{currentState(election)}}</span>
                <span class="caption text-itallic">{{new Date(election.timestamp * 1000).toDateString()}}</span>
              </v-list-item-content>
            </v-list-item>
            <v-divider :key="`divider-${index}`"/>
          </template>
        </v-list>
      </template>
      <v-container align-center fill-height v-else>
        <div class="text-center" style="width: 100%" v-if="loadingElections">
          <v-progress-circular indeterminate size="80" width="2" />
        </div>
        <div class="text-center" style="width: 100%" v-else>
          <v-icon size="100">mdi-vote-outline</v-icon>
          <p class="grey--text">No Elections found</p>
          <v-btn tile color="primary" class="text-capitalize" :loading="loadingElections" @click="loadElections">
            <v-icon class="mr-2">mdi-refresh</v-icon>
            <span>Refresh</span>
          </v-btn>
        </div>
      </v-container>
    </v-navigation-drawer>
    <v-main>
      <v-container style="margin-top: 48px; margin-left: 30%; width: calc(100vw - 30%); min-height: calc(100vh - 48px);" class="pa-0" grid-list-xl v-if="elections.length > 0">
        <div class="pa-4">
          <h1 class="title text-capitalize">{{selectedElection.name}}</h1>
          <p class="body-1">
            <v-chip>{{selectedElection.address}}</v-chip>
          </p>
          <span class="caption">{{currentState(selectedElection)}}</span><br>
          <span class="caption">{{new Date(selectedElection.timestamp * 1000).toDateString()}}</span><br>
          <v-btn tile color="primary" class="text-capitalize mt-3" @click="nextState(selectedElection).transition()" :disabled="selectedElection.electionIsClosed" :loading="activatingVoting || closingElection">
            <span>{{nextState(selectedElection).text}}</span>
          </v-btn>
        </div>
        <v-tabs v-model="tab">
          <v-tab :key="0" class="text-capitalize font-weight-bold">Candidates ({{selectedElection.numberOfCandidates}})</v-tab>
          <v-tab :key="1" class="text-capitalize font-weight-bold">Voters ({{selectedElection.numberOfVoters}})</v-tab>
        </v-tabs>
        <v-tabs-items v-model="tab" class="transparent mt-5">
          <v-tab-item :key="0">
            <center v-if="selectedElection.numberOfCandidates == 0">
              <v-icon size="100">mdi-account-outline</v-icon>
              <p class="grey--text">No Candidates found</p>
              <v-btn tile color="primary" v-if="selectedElection.registrationIsActive" class="text-capitalize" @click="showAddCandidateDialog = true">
                <v-icon class="mr-2">mdi-account-plus-outline</v-icon>
                <span>Add Candidate</span>
              </v-btn>
            </center>
            <div v-else class="ma-5 mt-0">
              <v-btn tile color="primary" v-if="selectedElection.registrationIsActive" class="text-capitalize" @click="showAddCandidateDialog = true">
                <v-icon class="mr-2">mdi-account-plus-outline</v-icon>
                <span>Add Candidate</span>
              </v-btn>
              <v-list v-for="(candidate, index) in candidates" :key="index" class="my-3">
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-account-outline</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <span class="caption">Name</span>
                    <span>{{candidate.name}}</span>
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-network</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <span class="caption">Candidate address</span>
                    <span>{{candidate.address}}</span>
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-vote-outline</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <span class="caption">Number Of Votes</span>
                    <span>{{candidate.numberOfVotes}}</span>
                  </v-list-item-content>
                </v-list-item>
              </v-list>
            </div>
          </v-tab-item>
          <v-tab-item :key="1">
            <center v-if="selectedElection.numberOfVoters == 0">
              <v-icon size="100">mdi-vote-outline</v-icon>
              <p class="grey--text">No Voters found</p>
              <v-btn tile color="primary" v-if="selectedElection.registrationIsActive" class="text-capitalize" @click="showRegisterVoterDialog = true">
                <v-icon class="mr-2">mdi-vote-outline</v-icon>
                <span>Add Voter</span>
              </v-btn>
            </center>
            <div v-else class="ma-5">
              <v-form ref="getVoterForm" @submit.prevent="callGetVoter">
                <v-layout align-center>
                  <v-flex>
                    <v-text-field outlined dense prepend-inner-icon="mdi-magnify" label="Find voter" hide-details v-model="voterAddressSearchString" :rules="[requiredLengthRule(42, 42), validateEthAddress]" />
                  </v-flex>
                  <v-btn tile color="primary" v-if="selectedElection.registrationIsActive" class="text-capitalize" @click="showRegisterVoterDialog = true">
                    <v-icon class="mr-2">mdi-vote-outline</v-icon>
                    <span>Add Voter</span>
                  </v-btn>
                </v-layout>
              </v-form>
              <v-list v-if="voter">
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-account-outline</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <span class="caption">Name</span>
                    <span>{{voter.name}}</span>
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-network</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <span>{{voter.address}}</span>
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon :color="voter.hasVoted? 'green' : 'red'">mdi-record</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <span>{{voter.hasVoted? 'voted' : 'not voted'}}</span>
                  </v-list-item-content>
                </v-list-item>
              </v-list>
            </div>
          </v-tab-item>
        </v-tabs-items>
      </v-container>
      <v-container align-center style="margin-top: 48px; margin-left: 30%; width: calc(100vw - 30%); height: calc(100vh - 48px);" fill-height v-else>
        <div class="text-center" style="width: 100%" v-if="loadingElections">
          <v-progress-circular indeterminate size="80" width="2" />
        </div>
        <div class="text-center" style="width: 100%" v-else>
          <p class="grey--text">Nothing here at the moment</p>
        </div>
      </v-container>
    </v-main>
    <v-dialog v-model="showSelectTrackerContractDialog" width="350" persistent>
      <v-card>
        <v-card-title>
          <v-icon class="mr-2">mdi-network</v-icon>
          <span class="body-1">Set Election Tracker Contract</span>
          <v-spacer/>
          <v-btn icon @click="showSelectTrackerContractDialog = false">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-card-title>
        <v-card-text class="mt-3">
          <v-form @submit.prevent="saveTrackerContractAddress" ref="trackerContractAddressForm">
            <v-text-field outlined label="Contract Address" v-model="localTrackerContractAddress" :rules="[requiredLengthRule(42, 42), validateEthAddress]"/>
            <v-btn type="submit" icon color="primary">
              <v-icon>mdi-arrow-right</v-icon>
            </v-btn>
          </v-form>
        </v-card-text>
      </v-card>
    </v-dialog>
    <v-dialog v-model="showCreateElectionDialog" width="350" persistent>
      <v-card>
        <v-card-title>
          <v-icon class="mr-2">mdi-vote-outline</v-icon>
          <span class="body-1">Create New Election</span>
          <v-spacer/>
          <v-btn icon @click="showCreateElectionDialog = false">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-card-title>
        <v-card-text>
          <v-form ref="createElectionForm" @submit.prevent="callCreateElection">
            <v-text-field outlined label="Election Name" v-model="newElectionName" :rules="[requiredRule]"/>
            <v-btn type="submit" icon color="primary" :loading="creatingNewElection">
              <v-icon>mdi-arrow-right</v-icon>
            </v-btn>
          </v-form>
        </v-card-text>
      </v-card>
    </v-dialog>
    <v-dialog v-model="showAddCandidateDialog" width="350" persistent>
      <v-card>
        <v-card-title>
          <v-icon class="mr-2">mdi-account-plus-outline</v-icon>
          <span class="body-1">Add Candidate</span>
          <v-spacer/>
          <v-btn icon @click="showAddCandidateDialog = false">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-card-title>
        <v-card-text>
          <v-form ref="addCandidateForm" @submit.prevent="callAddCandidate">
            <v-text-field outlined label="Voter Address" v-model="candidateAddress" :rules="[requiredLengthRule(42,42), validateEthAddress]" />
            <v-text-field outlined label="Full Name" v-model="candidateName" :rules="[requiredRule]" />
            <v-btn type="submit" icon color="primary" :loading="addingCandidate">
              <v-icon>mdi-arrow-right</v-icon>
            </v-btn>
          </v-form>
        </v-card-text>
      </v-card>
    </v-dialog>
    <v-dialog v-model="showRegisterVoterDialog" width="350" persistent>
      <v-card>
        <v-card-title>
          <v-icon class="mr-2">mdi-vote-outline</v-icon>
          <span class="body-1">Register Voter</span>
          <v-spacer/>
          <v-btn icon @click="showRegisterVoterDialog = false">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-card-title>
        <v-card-text>
          <v-form ref="registerVoterForm" @submit.prevent="callRegisterVoter">
            <v-text-field outlined label="Voter Address" v-model="voterAddress" :rules="[requiredLengthRule(42,42), validateEthAddress]" />
            <v-text-field outlined label="Full Name" v-model="voterName" :rules="[requiredRule]" />
            <v-btn type="submit" icon color="primary" :loading="registeringVoter">
              <v-icon>mdi-arrow-right</v-icon>
            </v-btn>
          </v-form>
        </v-card-text>
      </v-card>
    </v-dialog>
  </v-app>
</template>

<script src="./Dashboard.ts"></script>

<style lang="scss">
.v-navigation-drawer__border {
  display: none !important;
}
</style>