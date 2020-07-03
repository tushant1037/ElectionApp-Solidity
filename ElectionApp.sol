pragma solidity ^0.4.24;

contract Election {
    bool public start = false; //election is starting or not
    address owner; //address of deployer
    uint public startTime; //starting time of election
    uint public candidateCount = 0; // number of candidates
    string public winner; //winner
    
    enum State { Init, RegCandidates, RegVoters, Voting, Done } //stages of election
    State public state;
    
    //time given by deployer for arranging election.
    uint public RegCandidatesTime;
    uint public RegVotersTime;
    uint public VotingTime;
    
    //Candidates structure
    struct Candidate{
        uint id;
        string name;
        string party;
    }
    
    mapping(uint => Candidate) public candidatesList; // candiate list
    
    //voters structure
    struct Voter{
        uint id;
        address voterAddress;
        string name;
        bool voted;
    }
    
    mapping(address => Voter) public votersList; // voter List
    
    //votes count 
    struct VoteCount{
        uint id;
        string name;
        uint votes;
    }
    
    mapping(uint => VoteCount) public voteCountList; // vote count list
    
    //who can start election.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    uint public debug;

    //starting election function
    function StartElection(uint _RegCandidatesTime, uint _RegVotersTime, uint _VotingTime) onlyOwner public {
        start = true;
        RegCandidatesTime = _RegCandidatesTime;
        RegVotersTime = _RegVotersTime;
        VotingTime = _VotingTime;
        startTime = now;
        state = State.RegCandidates;
    }
    
    //Registration of Candidates
    function RegisterCandidates(uint _id, string _name, string _party) onlyOwner public {
        if (state != State.RegCandidates) {return;}
        if (start != true) {return;}
        candidatesList[_id] = Candidate(_id,_name,_party);
        voteCountList[_id] = VoteCount(_id, _name, 0);
        candidateCount = candidateCount + 1;
        if (now > (startTime + RegCandidatesTime)) { state = State.RegVoters; }
    }
    
    //Registration of Voters
    function RegisterVoters(uint _id, address _voterAddress, string _name) onlyOwner public {
        if (state != State.RegVoters) {return;}
        if (start != true) {return;}
        votersList[_voterAddress] = Voter(_id, _voterAddress , _name, false);
        if (now > (startTime + RegCandidatesTime + RegVotersTime)) { state = State.Voting; }
    }
    
    function FunVoting(address _voterAddress,uint _id) public {
        if (state != State.Voting) {return;}
        if (start != true) {return;}
        bool voterVoted = votersList[_voterAddress].voted;
        if (voterVoted == true) {return;}
        voteCountList[_id].votes = voteCountList[_id].votes + 1;
        votersList[_voterAddress].voted = true;
        if (now > (startTime + RegCandidatesTime + RegVotersTime + VotingTime)) { state = State.Done; }
    }
    
    function DisplayResult() public view returns(string){
        uint winningVoteCount = 0;
        //uint winnerId;
        for (uint prop = 0; prop < candidateCount; prop++) {
            if (voteCountList[prop].votes > winningVoteCount) {
                winningVoteCount = voteCountList[prop].votes;
                winner = voteCountList[prop].name;
                //winnerId = voteCountList[prop].id;
            }
        }
        return winner;
    }
    
    //getting stage of election function
    function getState() public view returns(State){
        return state;
    }
    
    
}